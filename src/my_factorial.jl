function my_factorial(n)
    if n == 0
        BigInt(1)
    end
    fact = BigInt(1);
    for i=1:n
        fact *= i;
    end
    return fact
end
