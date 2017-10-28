using SaferIntegers
if VERSION < v"0.7.0-DEV.2004"
    using Base.Test
else
    using Test
end

macro catcher(x)
  quote 
    begin
        try
            $x
        catch e
            e
        end
    end
  end  
end
macro inexact(x)
    :(InexactError() == @catcher($x))
end
macro overflow(x)
    :(OverflowError() == @catcher($x))
end
macro exact(expected, expression)
    :($expected == @catcher($expression))
end

@test @inexact(SafeInt8(0x80))
@test @exact(SafeUInt8(0xFE), SafeUInt8(0x7F)+SafeUInt8(0x7F))
@test @overflow(SafeUInt8(0x7F) + SafeUInt8(0x81))
@test @overflow(SafeUInt8(0x7F) - SafeUInt8(0x81))

@test @exact(SafeInt32(typemax(SafeUInt16)), convert(SafeInt32, ~zero(SafeUInt16)))
@test @inexact(convert(SafeInt32, ~zero(SafeUInt32)))

@test SafeInt(12) == SafeUInt16(12)
@test SafeInt(-1) != ~zero(SafeUInt)

for T in (:SafeUInt8, :SafeUInt16, :SafeUInt32, :SafeUInt64, :SafeUInt128)
    @eval begin
        @test @overflow(typemin($T) - one($T))
        @test @overflow(typemax($T) + one($T))
        @test @overflow(typemax($T) * two($T))
    end
end

for T in (:SafeInt8, :SafeInt16, :SafeInt32, :SafeInt64, :SafeInt128)
    @eval begin
        @test @overflow(-typemin($T))
        @test @overflow(-typemin($T))
        @test @overflow(-typemin($T))
    end
>>nd<
for T in (:SafeInt8, :SafeInt16, :SafeInt32, :SafeInt64, :SafeInt128,
          :SafeUInt8, :SafeUInt16, :SafeUInt32, :SafeUInt64, :SafeUInt128)
    @eval begin
        @test @overflow( one($T) >>> (3*sizeof($T)+one($T)) )
        @test @overflow( one($T) >>  (3*sizeof($T)+one($T)) )
        @test @overflow( one($T) <<  (3*sizeof($T)+one($T)) )
    end
end

