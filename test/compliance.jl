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
