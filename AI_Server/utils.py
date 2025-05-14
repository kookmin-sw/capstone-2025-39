def extract_weather_data(json_response):
    """
    기상청 API 응답 JSON에서 필요한 데이터만 추출합니다.
    """
    if json_response.get("response") and json_response["response"].get("body") and json_response["response"]["body"].get("items"):
        items = json_response["response"]["body"]["items"]["item"]
        processed_items = []
        # 허용할 카테고리 목록
        allowed_categories = ["T1H", "RN1", "SKY", "PTY", "WSD"]
        for item in items:
            # 카테고리 필터링 조건 추가
            if item.get("category") in allowed_categories:
                processed_item = {
                    "category": item.get("category"),
                    "fcstDate": item.get("fcstDate"),
                    "fcstTime": item.get("fcstTime"),
                    "fcstValue": item.get("fcstValue")
                }
                processed_items.append(processed_item)
        return processed_items
    else:
        return "Error: 날씨예보 데이터를 가져오지 못했습니다."