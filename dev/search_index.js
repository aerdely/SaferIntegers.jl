var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Overview",
    "title": "Overview",
    "category": "page",
    "text": ""
},

{
    "location": "#SaferIntegers-1",
    "page": "Overview",
    "title": "SaferIntegers",
    "category": "section",
    "text": ""
},

{
    "location": "#These-integer-types-do-not-ignore-arithmetic-overflows-and-underflows.-1",
    "page": "Overview",
    "title": "These integer types do not ignore arithmetic overflows and underflows.",
    "category": "section",
    "text": ""
},

{
    "location": "#Copyright-2018-2019-by-Jeffrey-Sarnoff.-This-work-is-made-available-under-The-MIT-License.-1",
    "page": "Overview",
    "title": "Copyright ©2018-2019 by Jeffrey Sarnoff. This work is made available under The MIT License.",
    "category": "section",
    "text": ""
},

{
    "location": "#A-Safer-Way-1",
    "page": "Overview",
    "title": "A Safer Way",
    "category": "section",
    "text": "Using the default Int or UInt types allows overflow and underflow errors to occur silently, without notice. These incorrect values propagate and such errors are difficult to recognize after the fact.This package exports safer versions. These types check for overflow and underflow in each of the basic arithmetic functions. The processing will stop with a message in the event of overflow or underflow.  On one machine, the overhead relative to the built-in integer types is <= 1.2x."
},

{
    "location": "#Background-1",
    "page": "Overview",
    "title": "Background",
    "category": "section",
    "text": "Integer overflow occurs when an integer type is increased beyond its maximum value. Integer underflow occurs when an integer type is decreased below its minimum value.  Signed and Unsigned values are subject to overflow and underflow.  With Julia, you can see the rollover using Int or UInt types:   typemax(Int) + one(Int) < 0\n   typemin(Int) - one(Int) > 0\n   typemax(UInt) + one(UInt) == typemin(UInt)\n   typemin(UInt) - one(UInt) == typemax(UInt)\n   ```\nThere are security implications for integer overflow in certain situations.julia  for i in 1:a     secure(biohazard[i])  enda = Int16(456) * Int16(567)  a == -3592 # and the for loop does not execute\n## Highlights\n\n### Why Does This Package Exist?\n\n- Your work may require that integer calculations be secure, well-behaved or unsurprising.\n\n- Your clients may expect your package/app/product calculates with care and correctness.\n\n- Your software may become part of a system on which the health or assets of others depends.\n\n- Your prefer to publish research results that are free of error, and you work with integers.\n\n### What Does This Package Offer?\n\n- **SaferIntegers** lets you work more cleanly and always alerts otherwise silent problems.\n\n- This package is designed for easy use and written to be performant in many sorts of use.\n\n- Using **SaferIntegers** can preclude some known ways that insecure systems are breached.\n\n----\n\n## A Basic Guide\n\nTo use safer integers within your computations, where you have been using    \nexplict digit sequences put them inside the safe integer constructors,    \n`SafeInt(11)` or `SafeUInt(0x015A)` and similarly for the bitsize-named versions    \n`SafeInt8`, `SafeInt16` .. `SafeInt128` and `SafeUInt8` .. `SafeUInt128`   \n\nWhere you had used`Int` or `UInt` now use `SafeInt` or `SafeUInt` and similarly\nwith the bitsize-named versions.    \n\nSafeInt and SafeUInt give you these arithmetic operators:    \n`+`, `-`, `*`, `div`, `rem`, `fld`, `mod`, `^`    \nwhich have become overflow and underflow aware.\n\nThe Int and UInt types can fail at simple arithmetic        \nand will continue carrying the incorrectness forward.    \nThe validity of values obtained is difficult to ascertain.\n\nMost calculations proceed without incident, \nand when used SafeInts operate as Ints\nshould a calculation encouter an overflow or underflow, \n    we are alerted and the calculation does not proceed.\n\n#### Give them a whirl.\n\n> Get the package: `Pkg.add(\"SaferIntegers\")`     \n> Use the package:  `using SaferIntegers`     \n\n- These functions check for overflow/underflow automatically:    \n    - abs, (neg), (-), (+), (*), div, fld, cld, rem, mod, (^)\n    - so does (/), before converting to Float64\n\n## Exported Types and Constructors / Converters\n\n- `SafeInt8`, `SafeInt16`, `SafeInt32`, `SafeInt64`, `SafeInt128`    \n- `SafeUInt8`, `SafeUInt16`, `SafeUInt32`, `SafeUInt64`, `SafeUInt128`   \n- `SafeSigned`, `SafeUnsigned`, `SafeInteger`\n\nThey check for overflow, even when multiplied by the usual Int and UInt types.    \nOtherwise, they should be unsurprising.\n\n## Other Conversions \n\n`Signed(x::SafeSigned)` returns an signed integer of the same bitwidth as x    \n`Unsigned(x::SafeUnsigned)` returns an unsigned integer of the same bitwidth as x    \n`Integer(x::SafeInteger)` returns an Integer of the same bitwidth and either Signed or Unsigned as is x\n\n`SafeSigned(x::Signed)` returns a safe signed integer of the same bitwidth as x    \n`SafeUnsigned(x::Unsigned)` returns a safe unsigned integer of the same bitwidth as x    \n`SafeInteger(x::Integer)` returns a safe Integer of the same bitwidth and either Signed or Unsigned as is x\n\n## Supports\n\n- `signbit`, `sign`, `abs`, `abs2`\n- `count_ones`, `count_zeros`\n- `leading_zeros`, `trailing_zeros`, `leading_ones`, `trailing_ones`\n- `ndigits0z`\n- `isless`, `isequal`, `<=`, `<`, `==`, `!=`, `>=`, `>`\n- `>>>`, `>>`, `<<`, `+`, `-`, `*`, `\\`, `^`\n- `div`, `fld`, `cld`, `rem`, `mod`\n- `zero`, `one`\n- `typemin`, `typemax`, `widen` \n\n## Benchmarking (one one machine)\n\njulia v1.1-devjulia using SaferIntegers using BenchmarkTools BenchmarkTools.DEFAULTPARAMETERS.timetolerance=0.005@noinline function test(n, f, a,b,c,d)    result = a;    i = 0    while true        i += 1        i > n && break               result += f(d,c)+f(b,a)+f(d,b)+f(c,a)    end    return result endhundredths(x) = round(x, digits=2)a = 17; b = 721; c = 75; d = 567; sa, sb, sc, sd = SafeInt.((a, b, c, d)); n = 10_000;hundredths( (@belapsed test(n, +, sa, sb, sc, sd)) /             (@belapsed test(n, +, a, b, c, d))        ) 1.25hundredths( (@belapsed test(n, *, sa, sb, sc, sd)) /             (@belapsed test(n, *, a, b, c, d))        ) 1.25hundredths( (@belapsed test(n, div, sa, sb, sc, sd)) /             (@belapsed test(n, div, a, b, c, d))      ) 1.14 ```"
},

{
    "location": "#credits-1",
    "page": "Overview",
    "title": "credits",
    "category": "section",
    "text": "This work derives from JuliaMath/RoundingIntegers.jl"
},

{
    "location": "howtouse/#",
    "page": "How To Use",
    "title": "How To Use",
    "category": "page",
    "text": ""
},

{
    "location": "howtouse/#How-To-Use-1",
    "page": "How To Use",
    "title": "How To Use",
    "category": "section",
    "text": "Just use safe integer types in place of the usual integer types.  The rest is well handled."
},

{
    "location": "howtouse/#To-Write-Code-With-Safe-Integers-1",
    "page": "How To Use",
    "title": "To Write Code With Safe Integers",
    "category": "section",
    "text": "Use these exported typesSafeInt, SafeInt8, SafeInt16, SafeInt32, SafeInt64, SafeInt128\nSafeUInt, SafeUInt8 SafeUInt16, SafeUInt32, SafeUInt64, SafeUInt128"
},

{
    "location": "references/#",
    "page": "Refs",
    "title": "Refs",
    "category": "page",
    "text": ""
},

{
    "location": "references/#References-1",
    "page": "Refs",
    "title": "References",
    "category": "section",
    "text": ""
},

{
    "location": "references/#Carnegie-Mellon-Software-Engineering-Institute-1",
    "page": "Refs",
    "title": "Carnegie-Mellon Software Engineering Institute",
    "category": "section",
    "text": "Signed Integer Overflow\nUnsigned Integer Wrapping"
},

{
    "location": "references/#Lectures-1",
    "page": "Refs",
    "title": "Lectures",
    "category": "section",
    "text": "Secure Coding (Integer Security)\nInteger Arithmetic and Undefined Behavior"
},

]}
