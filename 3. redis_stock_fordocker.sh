for i in {1..250}; do
    sudo docker exec -it my-redis
    set apple:1:quantity 200
    quantity=$(redis-cli get apple:1:quantity)
    if [ "$quantity" -lt 1 ]; then
        echo "재고가 부족합니다. 현재 재고: $quantity";
        break;
    fi
    sudo decr apple:1:quantity
    echo "현재 재고: $quantity"
done
