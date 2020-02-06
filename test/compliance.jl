#=

Maybe there’s an actual issue here?

julia> @btime prod(Int128(i) for i in 1:30)
  1.707 ns (0 allocations: 0 bytes)
265252859812191058636308480000000


julia> @btime prod(SaferIntegers.SafeInt128(i) for i in 1:30)
  16.591 μs (0 allocations: 0 bytes)
265252859812191058636308480000000


This looks good though:
julia> @btime prod(SaferIntegers.SafeInt64(i) for i in 1:20)
  1.597 ns (0 allocations: 0 bytes)
2432902008176640000

=#

# (result::Integer, isoverflow::Bool) = op_with_overflow(x::I, y::I) where {I<:Integer}
using Base.Checked: add_with_overflow, sub_with_overflow, mul_with_overflow


# ----------------------------

# for Unsigned Integer Types


UT  = UInt128
U1  = one(UT)
UB  = 128
UBH = UB >> 1

const UBITS = UT(UB)
const HALFUBITS = UT(UBH)

const ULSBS  = (U1 << HALFUBITS) - U1


function u128mul_ovf(x::UT, y::UT)
   x_hi = x >> HALFUBITS
   x_lo = x &  ULSBS
   y_hi = y >> HALFUBITS
   y_lo = y &  ULSBS

   lowbits = x_lo * y_lo

   x_hi_z = iszero(x_hi)
   y_hi_z = iszero(y_hi)
   x_hi_z && y_hi_z && return lowbits, false

   ovf = !(x_hi_z || y_hi_z)

   midbits1 = x_lo * y_hi
   midbits2 = x_hi * y_lo
   midbits  = midbits1 + midbits2
   ovf = ovf || midbits < midbits1 || midbits > ULSBS

   product = lowbits + (midbits << HALFUBITS)
   ovf = ovf || product < lowbits

   return product, ovf
end


UT8  = UInt8
U81  = one(UT8)
UB8  = 8
UB8H = UB8 >> 1

const U8BITS = UT(UB8)
const HALFU8BITS = UT(UB8H)

const U8LSBS  = (U81 << HALFU8BITS) - U81


function u8mul_ovf(x::UT8, y::UT8)
   x_hi = x >> HALFU8BITS
   x_lo = x &  U8LSBS
   y_hi = y >> HALFU8BITS
   y_lo = y &  U8LSBS

   lowbits = x_lo * y_lo

   x_hi_z = iszero(x_hi)
   y_hi_z = iszero(y_hi)
   x_hi_z && y_hi_z && return lowbits, false

   ovf = !(x_hi_z || y_hi_z)

   midbits1 = x_lo * y_hi
   midbits2 = x_hi * y_lo
   midbits  = midbits1 + midbits2
   ovf = ovf || midbits < midbits1 || midbits > U8LSBS

   product = lowbits + (midbits << HALFU8BITS)
   ovf = ovf || product < lowbits

   return product, ovf
end


u8s = collect(UInt8(0):UInt8(255));

function test_u8s()
   
   for a in u8s
      for b in u8s
         ab1, ovf1 = mul_with_overflow(a, b)
         ab2, ovf2 = u8mul_ovf(a, b)
         if ovf1 != ovf2
            println(string("UInt8:  a,b = ",a,", ",b,"    ovf1,ovf2 = ",ovf1,", ",ovf2))
            return true
         end
         if ab1 != ab2
            println(string("UInt8:  a,b = ",a,", ",b,"    ab1,ab2 = ",ab1,", ",ab2))
            return true
         end
      end
   end
   
   return nothing
end

test_u8s()

u128s = rand(UInt128, 2048) .>> rand(32:96, 2048);

function test_u128s()
   
   for a in u128s
      for b in u128s
         ab1, ovf1 = mul_with_overflow(a, b)
         ab2, ovf2 = u128mul_ovf(a, b)
         if ovf1 != ovf2
            println(string("UInt128:  a,b = ",a,", ",b,"    ovf1,ovf2 = ",ovf1,", ",ovf2))
            return true
         end
         if ab1 != ab2
            println(string("UInt128:  a,b = ",a,", ",b,"    ab1,ab2 = ",ab1,", ",ab2))
            return true
         end
      end
   end
   
   return nothing
end

test_u128s()


@noinline function test_checked()
   
  for a in u128s
   for b in u128s
      ab1, ovf1 = mul_with_overflow(a, b)
   end
end
return nothing
end

@noinline function test_cobbled()   
  for a in u128s
   for b in u128s
      ab2, ovf2 = u128mul_ovf(a, b)
   end
end
return nothing
end

time_todo_mul_with_overflow = @belapsed test_checked()
time_todo_mul_ovf = @belapsed test_cobbled()

percentage_speedup = round(time_todo_mul_with_overflow / time_todo_mul_ovf, digits = 4)





#=
 
const LONG_BIT      = UInt128(128)
const HALF_LONG_BIT = UInt128(64)
const HALFSIZE_MAX = (one(UInt128) << HALF_LONG_BIT) - one(UInt128)


function umul_ovf(x::UInt128, y::UInt128)
   x_hi = x >> HALF_LONG_BIT
   x_lo = x &  HALFSIZE_MAX
   y_hi = y >> HALF_LONG_BIT
   y_lo = y &  HALFSIZE_MAX

   lowbits = x_lo * y_lo

   x_hi_z = iszero(x_hi)
   y_hi_z = iszero(y_hi)
   x_hi_z && y_hi_z && return lowbits, false

   ovf = !(x_hi_z || y_hi_z)

   midbits1 = x_lo * y_hi
   midbits2 = x_hi * y_lo
   midbits  = midbits1 + midbits2
   ovf = ovf || midbits < midbits1 || midbits > HALFSIZE_MAX

   product = lowbits + (midbits << HALF_LONG_BIT)
   ovf = ovf || product < lowbits

   return product, ovf
end


# -----------------------------


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




function mul_with_ovf(x::I, y::I) where {I<:Union{Signed, SafeSigned}}
    xsbit, xneg = isneg_negabs(x)
    ysbit, yneg = isneg_negabs(y)
    z = xneg * yneg
    ovf =  z < min(xneg, yneg)
    return xsbit === ysbit ? (z, ovf) : (-z, ovf)
end

function mul_with_ovf(x::I, y::I) where {I<:Union{Unsigned, SafeUnsigned}}
    z = x * y
    ovf = z < max(x,y)
    return z, ovf
end

function checkedmul(x::I, y::I) where {I<:Union{Int128, UInt128}}
   z, ovf = mul_with_ovf(x, y)
   ovf && throw(OverflowError("$x * $y"))
   return z
end





uint8 = uint8a = uint8b = collect(typemin(UInt8):typemax(UInt8));
int8  = int8a  = int8b  = collect(typemin(Int8):typemax(Int8));

umat = imat = uovf = iovf = Matrix(undef, typemax(UInt8), typemax(UInt8));


for r = 1:typemax(UInt8)
  a = int8[r]
  for c = 1:typemax(UInt8)
    b = int8[c]
    ab = a * b    
    imat[r,c] = ab
    p, ovf = Base.Checked.mul_with_overflow(Int8(a), Int8(b))
    iovf[r,c] = ovf
  end
end

for r = 1:typemax(UInt8)
  a = uint8[r]
  for c = 1:typemax(UInt8)
    b = uint8[c]
    ab = a * b    
    umat[r,c] = ab
    p, ovf = Base.Checked.mul_with_overflow(UInt8(a), UInt8(b))
    uovf[r,c] = ovf
  end
end

=#
