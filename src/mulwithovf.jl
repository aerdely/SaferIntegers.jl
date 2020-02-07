unsafe_leading_zeros(x::SafeInt128) = leading_zeros(reinterpret(Int128, x))
unsafe_leading_zeros(x::SafeInt64) = leading_zeros(reinterpret(Int64, x))
unsafe_leading_ones(x::SafeInt128) = leading_ones(reinterpret(Int128, x))
unsafe_leading_ones(x::SafeInt64) = leading_ones(reinterpret(Int64, x))

@inline unsafe_leading_zeros(x::S, y::S) where {S<:Union{SafeInt64,SafeInt128}} = unsafe_leading_zeros(x) + unsafe_leading_zeros(y)
unsafe_leading_ones(x::S, y::S) where {S<:Union{SafeInt64,SafeInt128}} = unsafe_leading_ones(x) + unsafe_leading_ones(y)
unsafe_leading_zerosones(x::S, y::S) where {S<:Union{SafeInt64,SafeInt128}} = unsafe_leading_zeros(x) + unsafe_leading_ones(y)
unsafe_leading_oneszeros(x::S, y::S) where {S<:Union{SafeInt64,SafeInt128}} = unsafe_leading_ones(x) + unsafe_leading_zeros(y)

@inline unsafe_remaining_zeros(x::SafeInt64, y::SafeInt64) = unsafe_leading_zeros(x, y) - 64
unsafe_remaining_ones(x::SafeInt64, y::SafeInt64) = unsafe_leading_ones(x, y) - 64
unsafe_remaining_zerosones(x::SafeInt64, y::SafeInt64) = unsafe_leading_zerosones(x, y) - 64
unsafe_remaining_oneszeros(x::SafeInt64, y::SafeInt64) = unsafe_leading_oneszeros(x, y) - 64

@inline unsafe_remaining_zeros(x::SafeInt128, y::SafeInt128) = unsafe_leading_zeros(x, y) - 128
unsafe_remaining_ones(x::SafeInt128, y::SafeInt128) = unsafe_leading_ones(x, y) - 128
unsafe_remaining_zerosones(x::SafeInt128, y::SafeInt128) = unsafe_leading_zerosones(x, y) - 128
unsafe_remaining_oneszeros(x::SafeInt128, y::SafeInt128) = unsafe_leading_oneszeros(x, y) - 128


@inline checked_multiply(x::SafeInt128, y::SafeInt128) = checked_multiply(Val{signbit(x)}, Val{signbit(y)}, x, y)
@inline function checked_multiply(::Type{Val{false}}, ::Type{Val{false}}, x::SafeInt128, y::SafeInt128)
   extra_bits = unsafe_remaining_zeros(x, y)
   extra_bits > 0 && return SafeInt128(Int128(x)*Int128(y))
   signbit(extra_bits) && throw(OverflowError("$(x) * $(y)"))
   !iszero(extra_bits) && return SafeInt128(Int128(x)*Int128(y))
   return x*y
end
function checked_multiply(::Type{Val{true}}, ::Type{Val{true}}, x::SafeInt128, y::SafeInt128)
   extra_bits = unsafe_remaining_ones(x, y)
   signbit(extra_bits) && throw(OverflowError("$(x) * $(y)"))
   !iszero(extra_bits) && return SafeInt128(Int128(x)*Int128(y))
   return x*y
end
function checked_multiply(::Type{Val{false}}, ::Type{Val{true}}, x::SafeInt128, y::SafeInt128)
   extra_bits = unsafe_remaining_zerosones(x, y)
   signbit(extra_bits) && throw(OverflowError("$(x) * $(y)"))
   !iszero(extra_bits) && return SafeInt128(Int128(x)*Int128(y))
   return x*y
end
function checked_multiply(::Type{Val{true}}, ::Type{Val{false}}, x::SafeInt128, y::SafeInt128)
   extra_bits = unsafe_remaining_oneszeros(x, y)
   signbit(extra_bits) && throw(OverflowError("$(x) * $(y)"))
   !iszero(extra_bits) && return SafeInt128(Int128(x)*Int128(y))
   return x*y
end



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

#=

function Base.Checked.mul_with_overflow(x::Int128, y::Int128)
    xsbit, xneg = isneg_negabs(x)
    ysbit, yneg = isneg_negabs(y)
    z = xneg * yneg
    ovf =  z <= min(xneg, yneg)
    return xsbit === ysbit ? (z, ovf) : (-z, ovf)
end

function Base.Checked.mul_with_overflow(x::UInt128, y::UInt128)
    z = x * y
    ovf = z <= max(x,y)
    return z, ovf
end


function Base.Checked.checked_mul(x::Int128, y::Int128)
   z, ovf = mul_with_overflow(x, y)
   ovf && throw(OverflowError("$x * $y"))
   return z
end

function Base.Checked.checked_mul(x::UInt128, y::UInt128)
   z, ovf = mul_with_overflow(x, y)
   ovf && throw(OverflowError("$x * $y"))
   return z
end
=#

function mul_with_ovf(x::Int128, y::Int128)
    xsbit, xneg = isneg_negabs(x)
    ysbit, yneg = isneg_negabs(y)
    z = xneg * yneg
    ovf =  z <= min(xneg, yneg)
    return xsbit === ysbit ? (z, ovf) : (-z, ovf)
end

function mul_with_ovf(x::UInt128, y::UInt128)
    z = x * y
    ovf = z <= max(x,y)
    return z, ovf
end

function checkedmul(x::I, y::I) where {I<:Union{Int128, UInt128}}
   z, ovf = mul_with_ovf(x, y)
   ovf && throw(OverflowError("$x * $y"))
   return z
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
