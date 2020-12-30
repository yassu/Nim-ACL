when not declared ATCODER_SEQ_ARRAY_UTILS:
  const ATCODER_SEQ_ARRAY_UTILS* = 1
  import strformat, macros, sequtils
  template makeSeq*(x:int; init):auto =
    when init is typedesc: newSeq[init](x)
    else: newSeqWith(x, init)
  macro Seq*(lens: varargs[int]; init):untyped =
    var a = fmt"{init.repr}"
    for i in countdown(lens.len - 1, 0): a = fmt"makeSeq({lens[i].repr}, {a})"
    parseStmt(fmt"""
block:
  {a}""")

  template fill*[T](a:var T, init) =
    when a isnot seq and a isnot array:
      a = init
    else:
      for v in a.mitems: fill(v, init)

  template makeArray*(x:int or Slice[int]; init):auto =
    var v:array[x, init.type]
    v

  macro Array*(lens: varargs[typed], init):untyped =
    var a = fmt"{init.repr}"
    for i in countdown(lens.len - 1, 0):
      a = fmt"makeArray({lens[i].repr}, {a})"
    parseStmt(fmt"""
block:
  var a = {a}
  when {init.repr} isnot typedesc:
    a.fill({init.repr})
  a""")


