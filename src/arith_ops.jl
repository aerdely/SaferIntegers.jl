function checked_mod1(x::T, y::T) where T<:Integer
    result = checked_mod(x, y)
    result = ifelse(result === zero(T), y, result)
    return result
end

function checked_fld1(x::T, y::T) where T<:Integer
    d = checked_div(x, y)
    return d + (!signbit(x ⊻ y) & (d * y !== x))
end

for (OP, CHK) in ((:(+), :checked_add), (:(-), :checked_sub),
                  (:(*), :checked_mul), (:div, :checked_div),
                  (:fld, :checked_fld), (:cld, :checked_cld),
                  (:rem, :checked_rem), (:mod, :checked_mod),
                  (:mod1, :checked_mod1), (:fld1, :checked_fld1))
    @eval begin
       @inline function $OP(x::T, y::T) where T<:SafeSigned
            ix = baseint(x)
            iy = baseint(y)
            result = $CHK(ix, iy)
            return safeint(result)
       end
        
       @inline function $OP(x::T, y::T) where T<:SafeUnsigned
            ix = baseint(x)
            iy = baseint(y)
            result = $CHK(ix, iy)
            return safeint(result)
       end

       @inline function $OP(x::T1, y::T2) where {T1<:SafeSigned, T2<:SafeSigned}
            xx, yy = promote(x, y)
            ix = baseint(xx)
            iy = baseint(yy)
            result = $CHK(ix, iy)
            return safeint(result)
        end

        @inline function $OP(x::T1, y::T2) where {T1<:SafeUnsigned, T2<:SafeUnsigned}
            xx, yy = promote(x, y)
            ix = baseint(xx)
            iy = baseint(yy)
            result = $CHK(ix, iy)
            return safeint(result)
        end

        @inline function $OP(x::T1, y::T2) where {T1<:SafeSigned, T2<:SafeUnsigned}
            xx, yy = promote(x, y)
            ix = baseint(xx)
            iy = baseint(yy)
            result = $CHK(ix, iy)
            return safeint(result)
        end

        @inline function $OP(x::T1, y::T2) where {T1<:SafeUnsigned, T2<:SafeSigned}
            xx, yy = promote(x, y)
            ix = baseint(xx)
            iy = baseint(yy)
            result = $CHK(ix, iy)
            return safeint(result)
        end

        @inline function $OP(x::T1, y::T2) where {T1<:SafeInteger, T2<:Signed}
            xx, yy = promote(x, y)
            return $OP(xx, yy)
        end

        @inline function $OP(x::T1, y::T2) where {T1<:Signed, T2<:SafeInteger}
            xx, yy = promote(x, y)
            return $OP(xx, yy)
        end

        @inline function $OP(x::T1, y::T2) where {T1<:SafeInteger, T2<:Unsigned}
            xx, yy = promote(x, y)
            return $OP(xx, yy)
        end

        @inline function $OP(x::T1, y::T2) where {T1<:Unsigned, T2<:SafeInteger}
            xx, yy = promote(x, y)
            return $OP(xx, yy)
        end

        @inline function $OP(x::T, y::Bool) where {T<:SafeInteger}
            xx, yy = promote(x, y)
            return $OP(xx, yy)
        end

        @inline function $OP(x::Bool, y::T) where {T<:SafeInteger}
            xx, yy = promote(x, y)
            return $OP(xx, yy)
        end
    end
end


function (/)(x::S, y::S) where S<:SafeInteger
    ix = baseint(x)
    iy = baseint(y)
    checked_div(ix, iy)
    result = ix / iy
    return result
end
function (/)(x::S1, y::S2) where {S1<:SafeInteger, S2<:SafeInteger}
   xx, yy = promote(x, y)
   return (/)(xx, yy)
end
function (/)(x::S, y::I) where {S<:SafeInteger, I<:Signed}
   xx, yy = promote(x, y)
   return (/)(xx, yy)
end
function (/)(x::I, y::S) where {I<:Signed, S<:SafeInteger}
   xx, yy = promote(x, y)
   return (/)(xx, yy)
end
function (/)(x::S, y::I) where {S<:SafeInteger, I<:Unsigned}
   xx, yy = promote(x, y)
   return (/)(xx, yy)
end
function (/)(x::I, y::S) where {I<:Unsigned, S<:SafeInteger}
   xx, yy = promote(x, y)
   return (/)(xx, yy)
end


function (\)(x::S, y::S) where S<:SafeInteger
    ix = baseint(y)
    iy = baseint(x)
    checked_div(ix, iy)
    result = ix \ iy
    return result
end
function (\)(x::S1, y::S2) where {S1<:SafeInteger, S2<:SafeInteger}
   xx, yy = promote(x, y)
   return (\)(xx, yy)
end
function (\)(x::S, y::I) where {S<:SafeInteger, I<:Signed}
   xx, yy = promote(x, y)
   return (\)(xx, yy)
end
function (\)(x::I, y::S) where {I<:Signed, S<:SafeInteger}
   xx, yy = promote(x, y)
   return (\)(xx, yy)
end
function (\)(x::S, y::I) where {S<:SafeInteger, I<:Unsigned}
   xx, yy = promote(x, y)
   return (\)(xx, yy)
end
function (\)(x::I, y::S) where {I<:Unsigned, S<:SafeInteger}
   xx, yy = promote(x, y)
   return (\)(xx, yy)
end


function divrem(x::S, y::S) where S<:SafeInteger
    ix = baseint(x)
    iy = baseint(y)
    return safeint(div(ix, iy)), safeint(rem(ix, iy)) # div, rem already are checked
end
function divrem(x::S1, y::S2) where {S1<:SafeInteger, S2<:SafeInteger}
   xx, yy = promote(x, y)
   return divrem(xx, yy)
end
function divrem(x::S, y::I) where {S<:SafeInteger, I<:Signed}
   xx, yy = promote(x, y)
   return divrem(xx, yy)
end
function divrem(x::I, y::S) where {I<:Signed, S<:SafeInteger}
   xx, yy = promote(x, y)
   return divrem(xx, yy)
end
function divrem(x::S, y::I) where {S<:SafeInteger, I<:Unsigned}
   xx, yy = promote(x, y)
   return divrem(xx, yy)
end
function divrem(x::I, y::S) where {I<:Unsigned, S<:SafeInteger}
   xx, yy = promote(x, y)
   return divrem(xx, yy)
end


function fldmod(x::S, y::S) where S<:SafeInteger
    ix = baseint(x)
    iy = baseint(y)
    return safeint(fld(ix, iy)), safeint(mod(ix, iy)) # fld, mod already are checked
end
function fldmod(x::S1, y::S2) where {S1<:SafeInteger, S2<:SafeInteger}
   xx, yy = promote(x, y)
   return fldmod(xx, yy)
end
function fldmod(x::S, y::I) where {S<:SafeInteger, I<:Signed}
   xx, yy = promote(x, y)
   return fldmod(xx, yy)
end
function fldmod(x::I, y::S) where {I<:Signed, S<:SafeInteger}
   xx, yy = promote(x, y)
   return fldmod(xx, yy)
end
function fldmod(x::S, y::I) where {S<:SafeInteger, I<:Unsigned}
   xx, yy = promote(x, y)
   return fldmod(xx, yy)
end
function fldmod(x::I, y::S) where {I<:Unsigned, S<:SafeInteger}
   xx, yy = promote(x, y)
   return fldmod(xx, yy)
end


function fldmod1(x::S, y::S) where S<:SafeInteger
    ix = baseint(x)
    iy = baseint(y)
    return safeint(fld1(ix, iy)), safeint(mod1(ix, iy)) # fld1, mod1 already are checked
end
function fldmod1(x::S1, y::S2) where {S1<:SafeInteger, S2<:SafeInteger}
   xx, yy = promote(x, y)
   return fldmod1(xx, yy)
end
function fldmod1(x::S, y::I) where {S<:SafeInteger, I<:Signed}
   xx, yy = promote(x, y)
   return fldmod1(xx, yy)
end
function fldmod1(x::I, y::S) where {I<:Signed, S<:SafeInteger}
   xx, yy = promote(x, y)
   return fldmod1(xx, yy)
end
function fldmod1(x::S, y::I) where {S<:SafeInteger, I<:Unsigned}
   xx, yy = promote(x, y)
   return fldmod1(xx, yy)
end
function fldmod1(x::I, y::S) where {I<:Unsigned, S<:SafeInteger}
   xx, yy = promote(x, y)
   return fldmod1(xx, yy)
end


for F in (:gcd, :lcm)
  @eval begin
    function $F(x::S, y::S) where S<:SafeInteger
        ix = baseint(x)
        iy = baseint(y)
        return safeint($F(ix, iy))
    end
    function $F(x::S1, y::S2) where {S1<:SafeInteger, S2<:SafeInteger}
       xx, yy = promote(x, y)
       return $F(xx, yy)
    end
    function $F(x::S, y::I) where {S<:SafeInteger, I<:Signed}
       xx, yy = promote(x, y)
       return $F(xx, yy)
    end
    function $F(x::I, y::S) where {I<:Signed, S<:SafeInteger}
       xx, yy = promote(x, y)
       return $F(xx, yy)
    end
    function $F(x::S, y::I) where {S<:SafeInteger, I<:Unsigned}
       xx, yy = promote(x, y)
       return $F(xx, yy)
    end
    function $F(x::I, y::S) where {I<:Unsigned, S<:SafeInteger}
       xx, yy = promote(x, y)
       return $F(xx, yy)
    end
  end
end

function divgcd(x::S, y::S) where {S<:SafeInteger}
    g = gcd(x,y)
    return div(x,g), div(y,g)
end
divgcd(x::S1, y::S2) where {S1<:SafeInteger, S2<:SafeInteger} = divgcd(promote(x,y)...)
divgcd(x::I, y::S) where {I<:Signed, S<:SafeInteger} = divgcd(promote(x,y)...)
divgcd(x::S, y::I) where {S<:SafeInteger, I<:Signed} = divgcd(promote(x,y)...)
divgcd(x::I, y::S) where {I<:Unsigned, S<:SafeInteger} = divgcd(promote(x,y)...)
divgcd(x::S, y::I) where {S<:SafeInteger, I<:Unsigned} = divgcd(promote(x,y)...)
