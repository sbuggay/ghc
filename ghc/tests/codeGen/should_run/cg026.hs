-- !!! simple tests of primitive arrays
--
module Main ( main ) where

import PrelBase
import ST
import IOExts
import MutableArray
import ByteArray
import Addr
import Int( Num(fromInt) )
	
import Ratio
import Array

main = putStr
	 (test_chars	++ "\n"  ++
	  test_ints	++ "\n"  ++
	  test_addrs	++ "\n"  ++
	  test_floats	++ "\n"  ++
	  test_doubles	++ "\n"  ++
	  test_ptrs	++ "\n")


-- Arr# Char# -------------------------------------------
-- (main effort is in packString#)

test_chars :: String
test_chars
  = let str = reverse "Now is the time for all good men to come to...\n"
    in
    unsafePerformIO (
	_ccall_ fprintf (``stdout''::Addr) "%d %s\n" (93::Int) str >>
	_ccall_ fflush  (``stdout''::Addr)  >>
	return ""
	)

-- Arr# Int# -------------------------------------------

test_ints :: String
test_ints
  = let arr# = f 1000
    in
	shows (lookup_range arr# 42# 416#) "\n"
  where
    f :: Int -> ByteArray Int

    f size@(I# size#)
      = runST (
	    -- allocate an array of the specified size
	  newIntArray (0, (size-1))	>>= \ arr# ->

	    -- fill in all elements; elem i has i^2 put in it
	  fill_in arr# 0# (size# -# 1#) >>

	    -- freeze the puppy:
	  freezeIntArray arr#
	)

    fill_in :: MutableByteArray s Int -> Int# -> Int# -> ST s ()

    fill_in arr_in# first# last#
      = if (first# ># last#)
	then return ()
	else writeIntArray arr_in# (I# first#) (I# (first# *# first#)) >>
	     fill_in arr_in# (first# +# 1#) last#

    lookup_range :: ByteArray Int -> Int# -> Int# -> [Int]
    lookup_range arr from# to#
      = if (from# ># to#)
	then []
	else (indexIntArray arr (I# from#))
	     : (lookup_range arr (from# +# 1#) to#)

-- Arr# Addr# -------------------------------------------

test_addrs :: String
test_addrs
  = let arr# = f 1000
    in
	shows (lookup_range arr# 42# 416#) "\n"
  where
    f :: Int -> ByteArray Int

    f size@(I# size#)
      = runST (
	    -- allocate an array of the specified size
	  newAddrArray (0, (size-1))	>>= \ arr# ->

	    -- fill in all elements; elem i has i^2 put in it
	  fill_in arr# 0# (size# -# 1#) >>

	    -- freeze the puppy:
	  freezeAddrArray arr#
	)

    fill_in :: MutableByteArray s Int -> Int# -> Int# -> ST s ()

    fill_in arr_in# first# last#
      = if (first# ># last#)
	then return ()
	else writeAddrArray arr_in# (I# first#)
			    (A# (int2Addr# (first# *# first#))) >>
	     fill_in arr_in# (first# +# 1#) last#

    lookup_range :: ByteArray Int -> Int# -> Int# -> [ Int ]
    lookup_range arr from# to#
      = let
	    a2i (A# a#) = I# (addr2Int# a#)
	in
	if (from# ># to#)
	then []
	else (a2i (indexAddrArray arr (I# from#)))
	     : (lookup_range arr (from# +# 1#) to#)

-- Arr# Float# -------------------------------------------

test_floats :: String
test_floats
  = let arr# = f 1000
    in
	shows (lookup_range arr# 42# 416#) "\n"
  where
    f :: Int -> ByteArray Int

    f size@(I# size#)
      = runST (
	    -- allocate an array of the specified size
	  newFloatArray (0, (size-1))	>>= \ arr# ->

	    -- fill in all elements; elem i has "i * pi" put in it
	  fill_in arr# 0# (size# -# 1#) >>

	    -- freeze the puppy:
	  freezeFloatArray arr#
	)

    fill_in :: MutableByteArray s Int -> Int# -> Int# -> ST s ()

    fill_in arr_in# first# last#
      = if (first# ># last#)
	then return ()
{-	else let e = ((fromInt (I# first#)) * pi)
	     in trace (show e) $ writeFloatArray arr_in# (I# first#) e >>
	     fill_in arr_in# (first# +# 1#) last#
-}
	else writeFloatArray arr_in# (I# first#) ((fromInt (I# first#)) * pi) >>
	     fill_in arr_in# (first# +# 1#) last#

    lookup_range :: ByteArray Int -> Int# -> Int# -> [Float]
    lookup_range arr from# to#
      = if (from# ># to#)
	then []
	else (indexFloatArray arr (I# from#))
	     : (lookup_range arr (from# +# 1#) to#)

-- Arr# Double# -------------------------------------------

test_doubles :: String
test_doubles
  = let arr# = f 1000
    in
	shows (lookup_range arr# 42# 416#) "\n"
  where
    f :: Int -> ByteArray Int

    f size@(I# size#)
      = runST (
	    -- allocate an array of the specified size
	  newDoubleArray (0, (size-1))	>>= \ arr# ->

	    -- fill in all elements; elem i has "i * pi" put in it
	  fill_in arr# 0# (size# -# 1#) >>

	    -- freeze the puppy:
	  freezeDoubleArray arr#
	)

    fill_in :: MutableByteArray s Int -> Int# -> Int# -> ST s ()

    fill_in arr_in# first# last#
      = if (first# ># last#)
	then return ()
	else writeDoubleArray arr_in# (I# first#) ((fromInt (I# first#)) * pi) >>
	     fill_in arr_in# (first# +# 1#) last#

    lookup_range :: ByteArray Int -> Int# -> Int# -> [Double]
    lookup_range arr from# to#
      = if (from# ># to#)
	then []
	else (indexDoubleArray arr (I# from#))
	     : (lookup_range arr (from# +# 1#) to#)

-- Arr# (Ratio Int) (ptrs) ---------------------------------
-- just like Int# test

test_ptrs :: String
test_ptrs
  = let arr# = f 1000
    in
	shows (lookup_range arr# 42 416) "\n"
  where
    f :: Int -> Array Int (Ratio Int)

    f size
      = runST (
	  newArray (1, size) (3 % 5)	>>= \ arr# ->
	  -- don't fill in the whole thing
	  fill_in arr# 1 400		>>
	  freezeArray arr#
	)

    fill_in :: MutableArray s Int (Ratio Int) -> Int -> Int -> ST s ()

    fill_in arr_in# first last
      = if (first > last)
	then return ()
	else writeArray arr_in# first (fromInt (first * first)) >>
	     fill_in  arr_in# (first + 1) last

    lookup_range :: Array Int (Ratio Int) -> Int -> Int -> [Ratio Int]
    lookup_range array from too
      = if (from > too)
	then []
	else (array ! from) : (lookup_range array (from + 1) too)
