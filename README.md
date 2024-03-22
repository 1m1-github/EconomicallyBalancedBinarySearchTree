# EconomicallyBalancedBinarySearchTree
Library for log cost ordering with economic height rebalancing

A simple binary tree implementation.

Tree balancing is donr via a function `rebalance` that is to be called by independent economic entities.

The allows for tokenization of computing/energy efficiency. If the gas cost savings from having a balanced tree vs the current one is large enough, we can incentivize independent actors to rebalance for us, but only when it's worth rebalancing.

The current implementation of `rebalance` is first order only, i.e. the user provides the median. The function checks the median and remakes a tree around it. Can be expanded to provide new tree entitely from off-chain, where the node set is checked for equality.
