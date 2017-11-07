__precompile__()

module SaferIntegers

export SafeInteger, SafeSigned, SafeUnsigned,
       SafeInt, SafeInt8, SafeInt16, SafeInt32, SafeInt64, SafeInt128,
       SafeUInt, SafeUInt8, SafeUInt16, SafeUInt32, SafeUInt64, SafeUInt128

import Base: convert

abstract type SafeInteger  <: Integer end
abstract type SafeUnsigned <: SafeInteger end
abstract type SafeSigned   <: SafeInteger end

primitive type SafeInt8    <: SafeSigned     8 end
primitive type SafeInt16   <: SafeSigned    16 end
primitive type SafeInt32   <: SafeSigned    32 end
primitive type SafeInt64   <: SafeSigned    64 end
primitive type SafeInt128  <: SafeSigned   128 end

primitive type SafeUInt8   <: SafeUnsigned   8 end
primitive type SafeUInt16  <: SafeUnsigned  16 end
primitive type SafeUInt32  <: SafeUnsigned  32 end
primitive type SafeUInt64  <: SafeUnsigned  64 end
primitive type SafeUInt128 <: SafeUnsigned 128 end

if Sys.WORD_SIZE == 32
    const SafeInt  = SafeInt32
    const SafeUInt = SafeUInt32
else
    const SafeInt  = SafeInt64
    const SafeUInt = SafeUInt64
end

const UnsafeInteger = Union{Signed, Unsigned}
const SafeInteger   = Union{SafeSigned, SafeUnsigned}

const UNSAFE_SIGNEDS   = (:Int8, :Int16, :Int32, :Int64, :Int128)
const SAFE_SIGNEDS     = (:SafeInt8, :SafeInt16, :SafeInt32, :SafeInt64, :SafeInt128)
const UNSAFE_UNSIGNEDS = (:UInt8, :UInt16, :UInt32, :UInt64, :UInt128)
const SAFE_UNSIGNEDS   = (:SafeUInt8, :SafeUInt16, :SafeUInt32, :SafeUInt64, :SafeUInt128)
const UNSAFE_INTEGERS  = (:Int8, :UInt8, :Int16, :UInt16, :Int32, :UInt32, :Int64, :UInt64, :Int128, :UInt128)
const SAFE_INTEGERS    = (:SafeInt8, :SafeUInt8, :SafeInt16, :SafeUInt16, :SafeInt32,:SafeUInt32, :SafeInt64, :SafeUInt64, :SafeInt128, :SafeUInt128)

include("itypestype.jl")
include("convert.jl")
include("promote.jl")
include("int_ops.jl")
include("binary_ops.jl")
include("arith_ops.jl")
include("string_io.jl")

end # module SaferIntegers
