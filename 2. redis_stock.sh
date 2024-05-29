# 재고 감소 이런식으로 쓸 수 있다!

# 배쉬쉘은 이렇게 표시해주는게 기본
# !/bin/bash

# 200번 반복하면서 재고 확인 및 감소
for i in {1..250}; do
    quantity=$(redis-cli -h localhost -p 6379 get apple:1:quantity)
    if [ "$quantity" -lt 1 ]; then
        echo "재고가 부족합니다. 현재 재고: $quantity";
        break;
    fi
    redis-cli -h localhost -p 6379 decr apple:1:quantity
    echo "현재 재고: $quantity"
done


exec -it ac779 redis-cli
