sudo apt-get update
sudo apt-get install redis-server
redis-server --version

# 레디스 접속
# cli: command line interface
redis-cli

# 나가기
exit

# redis는 0번부터 15번까지의 database로 구성되어있다.
# 데이터베이스 선택
# 0번이 디폴트이다.
# 데이터베이스마다 저장돼있는 키값들이 다르다.
select 번호
select 1
select 15

# 데이터베이스 내에 모든 키를 조회할 수 있다.
keys * 

################# 일반 string 자료구조 ######################

# key:value 값 세팅 => set
# ""를 붙이지 않아도 문자열이다.
# 맵 저장소에서 key값은 유일하게 관리된다. => 이미 존재하는 키값이면 새로운 값으로 덮어쓰기 된다.
SET key값 value값
SET test_key1 test_value1

# 유저 이메일을 세팅해보자.
# 같은 키값을 넣으면 덮어쓰기 된다!
SET user:email:1 honggildong@naver.com
SET user:email:1 honggildong2@naver.com # 덮어쓰기 됨

# nx 옵션: not exist
SET user:email:1 hong@naver.com nx # 값이 안들어감. 키값이 없을때만 넣겠다는 뜻

# ex 옵션: 초단위로 만료시간을 줄 수 있다. - ttl(time to live)
# TTL 굉장히 유용하다!!!!!!
SET user:email:2 hong2@naver.com ex 20

# key 값을 통해 value를 얻기
GET key값
GET test_key1

# 특정 key 삭제
DEL user:email:1

# 현재 데이터베이스에 있는 모든 키값을 삭제
FLUSHDB


# 인스타그램 좋아요 기능 -> 아마 동시성 이슈 때문에 RDB 안썼을 것임
# 좋아요 기능은 Redis로 해야함
SET likes:posting:1 0  # 포스트 아이디 1번의 좋아요 개수가 0개였다.
INCR likes:posting:1 # 특정 키값의 value를 1만큼 증가시킨다.
DECR likes:posting:1 # 1 감소

# 문자열(예를 들어 "dd") 이런거 저장한 다음에 INCR하면 에러 나네

# redis는 모두 문자열 형태로 저장한다.

############################################################
# 재고 기능 구현
SET product:1:stock 100
DECR product:1:stock
GET product:1:stock

# INCR과 DECR은 하나씩만 줄일 수 있다.
# 그럼 회원이 5개 사면? => 다섯번 호출 => 불편하다.
# 나중에 HASH 같은 자료구조에서는 더 쉽게 연산할 수 있는 방법이 제공된다.


# bash쉘을 활용하여 재고감소 프로그램을 작성해보자.


###############################################################

# String 자료구조 == value가 스트링임
# 레디스의 자료구조는 value의 자료구조를 의미한다.

# key같은 user:email:1처럼 의미있는 문자열로 지정해주자.

# 어떤 목적으로 레디스가 사용됨?
# 레디스의 목적성: 고성능, 인증, 캐싱, 재고 관리 등으로 사용된다. -> 데이터의 일시적 보관/관리. 비정제된 데이터의 저장
# TTL (제한)
# 재고 관리는 반영구적으로 사용할 것임
# ex) 주식시세(영구 보관할 필요가 없음) -> 레디스로 관리 : 어차피 한국거래소에서 다 저장함. 그니까 서비스하는 사람은 일시저장해도됨
set user:email


flushdb # 모든 데이터 삭제

# SNS 서비스 -> 좋아요(트래픽 많은 서비스에서는 동시성 이슈 발생)


# 캐싱 기능 구현
# 1번 회원 정보 조회
# select name, email from author where id=1;
# 위 데이터의 결과값을 redis로 캐싱을 함: json 데이터 형식으로 저장

# json이라는 데이터 형식이 있음. 
# 중괄호 안에 키:밸류로 들어있는 형식이다.

set user:2:detail "{\"name\":\"hong2\", \"email\":\"hong2@naver.com\", \"age\":31}" ex 10

# 이걸 왜 할까를 고민해봐야함
# RDB에 있는 정보를 한번 더 Redis에 넣어놓는 이유
# 이유: 속도. 


############################
# list
# redis의 list는 자바의 deque와 같은 구조. (double ended queue)

# RPUSH, LPOP (오른쪽에서 넣고 왼쪽에서 뺌) -> 큐
# 데이터 왼쪽 삽입
LPUSH 키 밸류
# 데이터 오른쪽 삽입
RPUSH 키 밸류
# 데이터 왼쪽부터 꺼내기
LPOP 키
# 데이터 오른쪽부터 꺼내기
RPOP 키

####################################
## # 어떤 목적으로 사용?               #
## # 최근 본 상품 목록, 최근 방문한 페이지 #
###################################
RPUSH 키
RPOP 키

# hong3 hong2 hong1
LPUSH honggildongs hong1
LPUSH honggildongs hong2
LPUSH honggildongs hong3

# 꺼내서 보기만 하는 메소드
LRANGE honggildongs -1 -1 # 가장 오른쪽 값 꺼내서 보기
LRANGE honggildongs 0 0 # 가장 왼쪽 값 꺼내서 보기

# hong3
LPOP honggildongs

# 데이터 개수 조회
LLEN honggildongs

# 리스트의 요소 조회시에는 범위지정이 필요하다.
LRANGE honggildongs 0 -1 # 처음부터 끝까지
LRANGE 키 시작인덱스 끝인덱스

# list에  TTL을 적용하려면 전체 리스트에다가 줘야한다.
expire honggildongs 30

# TTL 조회
ttl honggildongs

# pop과 push 동시에 
# 페이지 뒤로가기 앞으로가기
RPOPLPUSH A리스트 B리스트

# 최근 방문한 페이지
# 5개 정도 데이터 push
# 최근 방문한 페이지 3개만 보여주기
RPUSH visited:page:prev 1
RPUSH visited:page:prev 2
RPUSH visited:page:prev 3
RPUSH visited:page:prev 4
RPUSH visited:page:prev 5


LRANGE visited:page:1 -3 -1 # 최근 3개만 보여주기

# 실습 2
# 뒤로가기 페이지를 누르면 뒤로 가기 페이지가 뭔지 출력
# 앞으로 가기 누르면 앞으로 간 페이지가 뭔지 출력
RPUSH visited:page:prev 1
RPUSH visited:page:prev 2
RPUSH visited:page:prev 3
RPUSH visited:page:prev 4
RPUSH visited:page:prev 5

# 뒤로가기한번
LRANGE visited:page:prev -1 -1
RPOPLPUSH visited:page:prev visited:page:next
# 뒤로가기 두번
LRANGE visited:page:prev -1 -1
RPOPLPUSH visited:page:prev visited:page:next

# 앞으로 가기 한번
LRANGE visited:page:next 0 0
RPUSH visited:page:prev LPOP visited:page:next

# LPOPRPUSH visited:page:next visited:page:prev



DEL visited:page:1

LRANGE visited:page:1 0 -1


###########################

## 실습: 최근 방문한 페이지로 실습할 것!
# 최근 본 상품 목록의 문제점: 같은걸 또 봤을때 문제가 된다.
# 중복 제거 && 순서 보장 -> sorted set
# 자바 자료구조: TreeSet

# 최근 방문한 페이지는 크게 문제가 없음

# 최근 본 상품 목록 => 나중에 sorted set(zset)을 활용하는 것이 적절
# 자료구조를 잘 알아야 서비스를 구현할때 잘 써먹을 수 있음

#################################
## set
# set 자료구조에 멤버 추가
sadd members member1
sadd members member2
sadd members member1

# set 조회
smembers members


# set에서 멤버 삭제
srem members member2

# set 멤버 개수 반환
scard members

# 특정 멤버가 set 안에 있는지 존재 여부 확인
# 있으면 1 없으면 0 반환
sismember members member3

# set으로 뭘 할 수 있을까?
# 매일 방문자 수 계산 -> 한 사람이 여러번 들어온 걸 한 번으로 카운트
sadd visit:2024-05-27 hong1@naver.com
sadd visit:2024-05-27 hong2@naver.com
sadd visit:2024-05-27 hong3@naver.com
sadd visit:2024-05-27 hong2@naver.com
sadd visit:2024-05-27 hong2@naver.com
sadd visit:2024-05-27 hong2@naver.com
scard visit:2024-05-27 # 방문자수 3 출력

# 그 외 set으로 할 수 있는 것
# 좋아요 수 관리, 조회수 등등


# zset (sorted set)
# 최근 본 상품 목록 => sorted set(zset)을 활용하는 것이 적절하다.
# score(숫자값을 줌)
ZADD zmembers 3 member1
ZADD zmembers 4 member2
ZADD zmembers 1 member3
ZADD zmembers 2 member4

# 조회를 할때 오름차순 정렬, 내림차순 정렬을 결정해주어야한다.
zrange zmembers 0 -1

# score 기준 내림차순 정렬
zrevrange zmembers 0 -1

# 새로운 값을 넣으면 스코어가 갈아끼워진다.

# zset 삭제
zrem zmembers member2

# 몇번째에 위치하고 있는지 확인
# zrank는 해당 멤버가 Index 몇번째인지 출력
zrank zmembers member2



# 실습: 최근 본 상품 목록 -> sorted set을 활용하는 것이 적절
zadd recent:products 192411 apple
zadd recent:products 192413 banana
zadd recent:products 192415 apple
zadd recent:products 192425 orange
zadd recent:products 192430 apple
zadd recent:products 192431 apple

##########################################

# hashes: 객체형 자료구조
hset product:1 name "apple" price 1000 stock 50

# 모든 객체 값 get
hgetall product:1

# 특정 요소값 수정
hset product:1 stock 40

# 특정 요소의 값을 증가
# stock을 5만큼 증가시키기
hincrby product:1 stock 5

# stock을 5만큼 감소시키기
hincrby product:1 stock -5
