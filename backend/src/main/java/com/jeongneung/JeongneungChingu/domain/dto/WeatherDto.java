package com.jeongneung.JeongneungChingu.domain.dto;

public class WeatherDto {
    private double temperature;      // 기온
    private double humidity;         // 습도
    private double rainfall60Min;    // 60분 강수량
    private double rainfallDay;      // 일 누적 강수량

    public WeatherDto(double temperature, double humidity, double rainfall60Min, double rainfallDay) {
        this.temperature = temperature;
        this.humidity = humidity;
        this.rainfall60Min = rainfall60Min;
        this.rainfallDay = rainfallDay;
    }

    public double getTemperature() { return temperature; }
    public double getHumidity() { return humidity; }
    public double getRainfall60Min() { return rainfall60Min; }
    public double getRainfallDay() { return rainfallDay; }
}
