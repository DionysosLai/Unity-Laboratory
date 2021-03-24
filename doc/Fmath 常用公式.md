# FMath 常用公式

20210312



## FMath::CeilLogTwo(uint32 value)

含义：返回大于等于value的以2为底数的最大N次幂的指数N（是指数，不是幂）。

例子：value=15，返回值为4，因为16是大于等于15的2的N次幂当中最小的次幂，其对应的指数为4。

 

## FMath::FloorLog2(uint32 value)

含义：与CeilLogTwo函数相反，返回小于等于value的以2为底数的最小N次幂的指数N。

例子：value=15，返回值为3，因为8是小于等于15的2的N次幂当中最大的次幂，其对应的指数为3。

 

## FMath::IsPowerOfTwo<T>(T value)

含义：判断value是否为2的幂。

例子：value=8则返回true，value=15返则回false。

 

FMath::RoundUpToPowerOfTwo(uint32 value)

含义：获取大于等于value的最小的2的幂。

例子：value=9则返回16，value=7则返回8
