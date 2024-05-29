while true; do
    # 사용자가 product를 입력할 때마다, 현재 시간을 score로 해서 zadd
    echo "원하는 상품 입력 또는 나가기(exit)"
    read product # 사용자의 입력값을 받을 수 있다.
    if [ "$product" == "exit" ]; then
        echo "bye"
        break
    fi
    timestamp=$(date +%s) # 날짜와
    echo "time:" + $timestamp
    redis-cli zadd recent:products $timestamp $product
done

echo "사용자의 최근 본 상품 목록 5개: "
redis-cli zrevrange recent:products 0 4
