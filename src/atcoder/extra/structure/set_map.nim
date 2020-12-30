when not declared ATCODER_SET_MAP_HPP:
  const ATCODER_SET_MAP_HPP* = 1
  import atcoder/extra/structure/randomized_binary_search_tree
  type SortedMultiSet*[K, T] = object
    rbst: RandomizedBinarySearchTree[K,void,RBSTNode[K, void, void], void,void]
  type SortedSet*[K, T] = object
    rbst: RandomizedBinarySearchTree[K,void,RBSTNode[K, void, void], void,void]
  type SortedMultiMap*[K, T] = object
    rbst: RandomizedBinarySearchTree[T,void,RBSTNode[T, void, void], void,void]
  type SortedMap*[K, T] = object
    rbst: RandomizedBinarySearchTree[T,void,RBSTNode[T, void, void], void,void]

  type anySet = SortedSet or SortedMultiSet
  type anyMap = SortedMap or SortedMultiMap

  type SetOrMap = SortedMultiSet or SortedSet or SortedMultiMap or SortedMap

  template getType*(T:typedesc[anySet], K):typedesc =
    T[K, K]
  template getType*(T:typedesc[anyMap], K, V):typedesc =
    T[K, (K, V)]

  proc init*(T:typedesc[SetOrMap]):T =
    result.rbst = initRandomizedBinarySearchTree[T.T]()
    result.rbst.root = nil

  proc initSortedMultiSet*[K]():auto = SortedMultiSet.getType(K).init()
  proc initSortedSet*[K]():auto = SortedSet.getType(K).init()
  proc initSortedMultiMap*[K, V]():auto = SortedMultiMap.getType(K, V).init()
  proc initSortedMap*[K, V]():auto = SortedMap.getType(K, V).init()

  #RBST(sz, [&](T x, T y) { return x; }, T()) {}
  
  template getKey*(self: SetOrMap, t:RBSTNode):auto =
    when self.type is anySet: t.key
    else: t.key[0]
  
  proc lower_bound*[T:SetOrMap](self: var T, t:var RBSTNode, x:T.K):int {.inline.}=
    if t == nil: return 0
    if x <= self.getKey(t): return self.lower_bound(t.l, x)
    return self.lower_bound(t.r, x) + self.rbst.count(t.l) + 1
  
  proc lower_bound*[T:SetOrMap](self:var T, x:T.K):int {.inline.} =
    self.lower_bound(self.rbst.root, x)

  proc upper_bound*[T:SetOrMap](self: var T, t:var RBSTNode, x:T.K):int {.inline.} =
    if t == nil: return 0
    if x < self.getKey(t): return self.upper_bound(t.l, x)
    return self.upper_bound(t.r, x) + self.rbst.count(t.l) + 1
  
  proc find*[T:SetOrMap](self: var T, t:var RBSTNode, x:T.K):RBSTNode {.inline.}=
    if t == nil: return nil
    if x < self.getKey(t): return self.find(t.l, x)
    elif x > self.getKey(t): return self.find(t.r, x)
    else: return t
  proc find*[T:SetOrMap](self:var T, x:T.K):auto {.inline.} =
    self.find(self.rbst.root, x)
  
  proc contains*[T:SetOrMap](self: var T, x:T.K):bool {.inline.} =
    self.find(x) != nil
  
  proc upper_bound*[T:SetOrMap](self: var T, x:T.K):int {.inline.} =
    self.upper_bound(self.rbst.root, x)
  
  proc kth_element*[T:SetOrmap](self: var T, t:RBSTNode, k:int):T.T {.inline.} =
    let p = self.rbst.count(t.l)
    if k < p: return self.kth_element(t.l, k)
    elif k > p: return self.kth_element(t.r, k - self.rbst.count(t.l) - 1)
    else: return t.key
  
  proc kth_element*[T:SetOrMap](self: var T, k:int):T.T {.inline.} =
    return self.kth_element(self.rbst.root, k)
  
  proc insert*[T:SortedMultiSet](self: var T, x:T.K) {.inline.} =
    self.rbst.insert(self.lower_bound(x), x)
  proc insert*[T:SortedMultiMap](self: var T, x:T.T) =
    self.rbst.insert(self.lower_bound(x[0]), x)
  
  proc count*[T:SetOrMap](self: var T, x:T.K):int {.inline.} =
    return self.upper_bound(x) - self.lower_bound(x)
  
  proc erase_key*[T:SetOrMap](self: var T, x:T.K) {.inline.} =
    if self.count(x) == 0: return
    self.rbst.erase(self.lower_bound(x))
  
  proc insert*[T:SortedSet](self: var T, x:T.K) {.inline.} =
    var t = self.find(x)
    if t != nil: return
    self.rbst.insert(self.lower_bound(x), x)
  proc insert*[T:SortedMap](self: var T, x:T.T) {.inline.} =
    var t = self.find(x[0])
    if t != nil: t.key = x
    else: self.rbst.insert(self.lower_bound(x[0]), x)
  proc `[]`*[K, V](self: var SortedMap[K, tuple[K:K, V:V]], x:K):auto {.inline.} =
    var t = self.find(x)
    if t != nil: return t.key[1]
    result = V.default
    self.insert((x, result))
  proc `[]=`*[K, V](self: var SortedMap[K, tuple[K:K, V:V]], x:K, v:V) {.inline.} =
    var t = self.find(x)
    if t != nil:
      t.key[1] = v
      return
    self.insert((x, v))
  
  proc len*(self:var SetOrMap):int {.inline.} = self.rbst.len()
  proc empty*(self:var SetOrMap):bool {.inline.} = self.rbst.empty()
