
def is_prime(n):
    if n <= 1:
        return False
    if n <= 3:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def count_primes(limit):
    count = 0
    for num in range(2, limit):
        if is_prime(num):
            count += 1
    return count


def handle(event, context):
    limit=1000000
    result = count_primes(limit)
    return f"Prime numbers amount in range 1-{limit}: {result}\n"
