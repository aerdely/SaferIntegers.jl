uint8 = uint8a = uint8b = collect(typemin(UInt8):typemax(UInt8));
int8  = int8a  = int8b  = collect(typemin(Int8):typemax(Int8));

umat = imat = uovf = iovf = Matrix(undef, typemax(UInt8), typemax(UInt8));


for r = 1:typemax(UInt8)
  a = int8[r]
  for c = 1:typemax(UInt8)
    b = int8[c]
    ab = a * b    
    imat[r,c] = ab
    c, ovf = Base.Checked.mul_with_overflow(Int8(a), Int8(b))
    iovf[r,c] = ovf
  end
end

for r = 1:typemax(UInt8)
  a = uint8[r]
  for c = 1:typemax(UInt8)
    b = uint8[c]
    ab = a * b    
    umat[r,c] = ab
    c, ovf = Base.Checked.mul_with_overflow(UInt8(a), UInt8(b))
    uovf[r,c] = ovf
  end
end
