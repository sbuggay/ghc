{-# LANGUAGE Generics #-}

module ShouldCompile0 where

-- We should be able to generate a generic representation for these types
data A

data B a

data C = C0 | C1

data D a = D0 | D1 { d11 :: a, d12 :: (D a) }

data E a = E0 a (E a) (D a)
