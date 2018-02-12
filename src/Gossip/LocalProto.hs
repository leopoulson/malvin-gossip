module Gossip.LocalProto where

import Gossip
import Gossip.Internal

import qualified Data.IntSet as IntSet

-- | Local protocols only depend on the current graph, without knowledge or any syntactical language
type LocalProtocol = Graph -> [Call]

localLns :: LocalProtocol
localLns ( n , s ) =
  [ (x,y) | x <- agentsOf n, y <- agentsOf n, y `IntSet.member` (n `at` x) &&  y `IntSet.notMember` (s `at` x) ]

localAnyCall :: LocalProtocol
localAnyCall ( n, _ ) = [ (x,y) | x <- agentsOf n, y <- IntSet.toList (n `at` x), x /= y ]

localNoCall :: LocalProtocol
localNoCall = const []

-- all sequences generated by a local protocol
localSequences :: LocalProtocol -> Graph -> [Sequence]
localSequences loproto gg
  | null (loproto gg) = [ [] ]
  | otherwise =
      [ c : rest | c <- loproto gg, rest <- localSequences loproto (call gg c) ]

-- Properties of local protocols --

isWeaklySucc :: LocalProtocol -> Graph -> Bool
isWeaklySucc loproto gg = any (isSolved . calls gg) (localSequences loproto gg)

isStronglySucc :: LocalProtocol -> Graph -> Bool
isStronglySucc loproto gg = all (isSolved . calls gg) (localSequences loproto gg)

isStronglyUnsucc :: LocalProtocol -> Graph -> Bool
isStronglyUnsucc loproto gg = all (not . isSolved . calls gg) (localSequences loproto gg)

solvableInits :: LocalProtocol -> Int -> [Graph]
solvableInits loproto k = filter (isWeaklySucc loproto) (allInits k)

interestingInits :: LocalProtocol -> Int -> [Graph]
interestingInits loproto = filter (not . isStronglySucc loproto) . solvableInits loproto
