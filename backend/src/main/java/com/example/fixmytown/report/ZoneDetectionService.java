package com.example.fixmytown.report;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;

import java.io.InputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ZoneDetectionService {

    private final Map<String, List<LatLng>> zoneMap;

    public ZoneDetectionService() {
        try {
            ObjectMapper mapper = new ObjectMapper();
            InputStream inputStream = getClass().getResourceAsStream("/zones/zones.json");
            zoneMap = mapper.readValue(inputStream, new TypeReference<>() {});
        } catch (Exception e) {
            throw new RuntimeException("Nu s-a putut încărca zones.json", e);
        }
    }

    public String getZoneFromCoordinates(double lat, double lng) {
        for (Map.Entry<String, List<LatLng>> entry : zoneMap.entrySet()) {
            if (isPointInPolygon(lat, lng, entry.getValue())) {
                return entry.getKey();
            }
        }
        return "Unknown Zone";
    }

    private boolean isPointInPolygon(double lat, double lng, List<LatLng> polygon) {
        int i, j;
        boolean result = false;
        for (i = 0, j = polygon.size() - 1; i < polygon.size(); j = i++) {
            double xi = polygon.get(i).getLat(), yi = polygon.get(i).getLng();
            double xj = polygon.get(j).getLat(), yj = polygon.get(j).getLng();

            boolean intersect = ((yi > lng) != (yj > lng)) &&
                    (lat < (xj - xi) * (lng - yi) / (yj - yi) + xi);
            if (intersect) result = !result;
        }
        return result;
    }
}
