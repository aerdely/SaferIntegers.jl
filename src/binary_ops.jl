for OP in (:(&), :(|), :(⊻))
    @eval begin

       @inline function $OP(x::T, y::T) where T<:SafeInteger
           ix = baseint(x)
           iy = baseint(y)
           result = $OP(ix, iy)
           return safeint(result)
       end

       @inline function $OP(x::T1, y::T2) where {T1<:SafeInteger, T2<:SafeInteger}
           xx, yy = promote(x, y)
           return $OP(xx, yy)
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

   end
end


for OP in (:(<), :(<=), :(>=), :(>), :(!=), :(==), :isless, :isequal)
    @eval begin

       @inline function $OP(x::T, y::T) where T<:SafeInteger
           ix = baseint(x)
           iy = baseint(y)
           result = $OP(ix, iy)
           return safeint(result)
       end

       @inline function $OP(x::T1, y::T2) where {T1<:SafeInteger, T2<:SafeInteger}
           xx, yy = promote(x, y)
           return $OP(xx, yy)
       end

       @inline function $OP(x::T1, y::T2) where {T1<:SafeSigned, T2<:Signed}
           xx, yy = promote(x, y)
           return $OP(xx, yy)
       end
       @inline function $OP(x::T1, y::T2) where {T1<:Signed, T2<:SafeSigned}
           xx, yy = promote(x, y)
           return $OP(xx, yy)
       end
       @inline function $OP(x::T1, y::T2) where {T1<:SafeSigned, T2<:Unsigned}
           xx, yy = promote(x, y)
           return $OP(xx, yy)
       end
       @inline function $OP(x::T1, y::T2) where {T1<:Unsigned, T2<:SafeSigned}
           xx, yy = promote(x, y)
           return $OP(xx, yy)
       end
       @inline function $OP(x::T1, y::T2) where {T1<:SafeUnsigned, T2<:Signed}
           xx, yy = promote(x, y)
           return $OP(xx, yy)
       end
       @inline function $OP(x::T1, y::T2) where {T1<:Signed, T2<:SafeUnsigned}
           xx, yy = promote(x, y)
           return $OP(xx, yy)
       end
       @inline function $OP(x::T1, y::T2) where {T1<:SafeUnsigned, T2<:Unsigned}
           xx, yy = promote(x, y)
           return $OP(xx, yy)
       end
       @inline function $OP(x::T1, y::T2) where {T1<:Unsigned, T2<:SafeUnsigned}
           xx, yy = promote(x, y)
           return $OP(xx, yy)
       end
        
   end
end

for OP in (:(>>>), :(>>), :(<<))
    @eval begin

       @inline function $OP(x::T, y::T) where T<:SafeInteger
            r1 = baseint(x)
            bitsof(T) < abs(r2) && throw(OverflowError("cannot shift $T by $y"))
            result = $OP(r1, r2)
            return reinterpret(T, result)
        end

        @inline function $OP(x::T1, y::T2) where {T1<:SafeInteger, T2<:SafeInteger}
            xx = baseint(x)
            yy = baseint(y)
            bitsof(T1) < abs(yy) && throw(OverflowError("cannot shift $T1 by $yy"))
            return reinterpret(T1, $OP(xx, yy))
        end

        @inline function $OP(x::S, y::Int) where {S<:SafeInteger}
            xx = baseint(x)
            bitsof(S) < abs(y) && throw(OverflowError("cannot shift $S by $y"))
            return reinterpret(S, $OP(xx, y))
        end

        @inline function $OP(x::I, y::S) where {I<:Signed, S<:SafeInteger}
            yy = baseint(y)
            bitsof(I) < abs(yy) && throw(OverflowError("cannot shift $I by $yy"))
            return reinterpret(I, $OP(x, yy))
        end
        @inline function $OP(x::S, y::I) where {S<:SafeInteger, I<:Signed}
            xx = baseint(x)
            bitsof(S) < abs(y) && throw(OverflowError("cannot shift $S by $y"))
            return reinterpret(S, $OP(xx, y))
        end
        @inline function $OP(x::I, y::S) where {I<:Unsigned, S<:SafeInteger}
            yy = baseint(y)
            bitsof(I) < abs(yy) && throw(OverflowError("cannot shift $I by $yy"))
            return reinterpret(I, $OP(x, yy))
        end
        @inline function $OP(x::S, y::I) where {S<:SafeInteger, I<:Unsigned}
            xx = baseint(x)
            bitsof(S) < abs(y) && throw(OverflowError("cannot shift $S by $y"))
            return reinterpret(S, $OP(xx, y))
        end

   end
end
