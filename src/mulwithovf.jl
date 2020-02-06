# negative of the absolute value of x
function negabs(x::I) where {I<:Base.Checked.SignedInt}
   signbit(x) ? x : -x
end
function isneg_abs(x::I) where {I<:Base.Checked.SignedInt}
    signbit(x) ? (true, -x) : (false, sx)
end
function isneg_negabs(x::I) where {I<:Base.Checked.SignedInt}
    signbit(x) ? (true, x) : (false, -x)
end

function imul(x::I, y::I) where {I<:Base.Checked.SignedInt}
    xsbit, xneg = isneg_negabs(x)
    ysbit, yneg = isneg_negabs(y)
    z = xneg * yneg
    ovf =  z <= min(xneg, yneg)
    return xsbit === ysbit ? (z, ovf) : (-z, ovf)
end

#=
mul_with_overflow(x::T, y::T) where {T<:SignedInt}   = checked_smul_int(x, y)
mul_with_overflow(x::T, y::T) where {T<:UnsignedInt} = checked_umul_int(x, y)

function checked_mul(x::T, y::T) where T<:SignedIng
    @_inline_meta
    z, b = mul_with_overflow(x, y)
    b && throw_overflowerr_binaryop(:*, x, y)
    z
end
=#

mul_ovf(x::Int32, y::Int32) = mul_with_overflow(x, y)
mul_ovf(x::Int64, y::Int64) = mul_with_overflow(x, y)

function mul_ovf(x::SafeInt32, y::SafeInt32)
    product, ovf = mul_with_overflow(baseint(x), baseint(y))
    return SafeInt32(product), ovf
end
function mul_ovf(x::SafeInt64, y::SafeInt64)
    product, ovf = mul_with_overflow(baseint(x), baseint(y))
    return SafeInt64(product), ovf
end


function mul_ovf(x::Int128, y::Int128)
    ures, ovf = umul_ovf(x%UInt128, y%UInt128)
    return ures%Int128, ovf
end
 
const LONG_BIT       = UInt128(128)
const HALF_LONG_BIT  = UInt128(64)
const HALFSIZE_MAX = (one(UInt128) << HALF_LONG_BIT) - one(UInt128)

function umul_checked(x::UInt128, y::UInt128)
   x_hi = x >> HALF_LONG_BIT
   x_lo = x &  HALFSIZE_MAX
   y_hi = y >> HALF_LONG_BIT
   y_lo = y &  HALFSIZE_MAX

   lowbits = x_lo * y_lo

   x_hi_z = iszero(x_hi)
   y_hi_z = iszero(y_hi)
   x_hi_z && y_hi_z && return lowbits, false

   ovf = !x_hi_z && !y_hi_z
   ovf && throw_overflowerr_binaryop(:*, x, y)

   midbits1 = x_lo * y_hi
   midbits2 = x_hi * y_lo
   midbits  = midbits1 + midbits2
   ovf = midbits < midbits1 || midbits > HALFSIZE_MAX

   product = lowbits + (midbits << HALF_LONG_BIT)
   ovf = ovf || product < lowbits
   ovf && throw_overflowerr_binaryop(:*, x, y)

   return product
end



function umul_ovf(x::UInt128, y::UInt128)
   x_hi = x >> HALF_LONG_BIT
   x_lo = x & HALFSIZE_MAX
   y_hi = y >> HALF_LONG_BIT
   y_lo = y & HALFSIZE_MAX

   lowbits = x_lo * y_lo

   x_hi_z = iszero(x_hi)
   y_hi_z = iszero(y_hi)
   x_hi_z && y_hi_z && return lowbits, false

   ovf = !x_hi_z && !y_hi_z

   midbits1 = x_lo * y_hi
   midbits2 = x_hi * y_lo
   midbits  = midbits1 + midbits2
   ovf = ovf || midbits < midbits1 || midbits > HALFSIZE_MAX

   product = lowbits + (midbits << HALF_LONG_BIT)
   ovf = ovf || product < lowbits

   return product, ovf
end


function mul_ovf(x::SafeInt128, y::SafeInt128)
    ures, ovf = umul_ovf(UInt128(x), UInt128(y))
    return SafeInt128(ures%Int128), ovf
end
 
function umul_ovf(x::SafeUInt128, y::SafeUInt128)
   product, ovf = umul_ovf(UInt128(x), UInt128(y)) 

   return SafeUInt128(product), ovf
end

prod_ovf(xs::Vector{T}) where {T<:Union{SafeSigned,SafeUnsigned}} = prod(xs)

function prod_ovf(xs::Vector{T}) where {T<:Union{SafeInt128,SafeUInt128}}
    ovf = false
    result = one(T)
    
    for x in xs
       result, ovf0 = mul_ovf(result, x)
       ovf = ovf | ovf0
       ovf && break
    end
    
    return result, ovf
end
