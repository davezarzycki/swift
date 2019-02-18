// RUN: %target-typecheck-verify-swift

@pure
struct V {
  mutating func add(_ that: V) {
  }
  func neg() -> V {
  }
}

class C {
  static var gv : V = V()
  var iv : V = V()
  func mu() { iv.add(V()) }
  func withF(_ arg: () -> V) { _ = arg() }
  var fn : () -> V = { return V() }
}

@pure struct S {
  static var gv : V = V()
  var iv : V = V()
  mutating func mu() { iv.add(V()) }
  func im() -> V { return iv }
  func withF(_ arg: () -> V) { _ = arg() }
  var fn : () -> V = { return V() }
}

protocol P1 {
  @pure func m()
}

@pure func goodFunction(_ s: S, _ c: C) -> (S, C, C) {
  let c2 = c
  _ = s.im()
  _ = s.iv
  var s2 = s
  s2.iv.add(V())
  s2.mu()
  func inner() -> V { return V() }
  s2.fn = inner
  s.withF(inner)
  s.withF({ V() })
  let cl = { V() }
  s.withF(cl)
  return (s2, c, c2)
}

@pure func badProcedure(_ s: S, _ c: C) {
  _ = s.iv
  _ = s.im()
  var copy = s
  copy.iv.add(V())
  copy.mu()

  // expected-error@+1 2{{pure functions cannot access impure semantics}}
  _ = c.iv
  // expected-error@+1 {{pure functions cannot access impure semantics}}
  c.iv.add(V())
  // expected-error@+1 {{pure functions cannot access impure semantics}}
  c.mu()
  func inner() -> V { return V() }
  // expected-error@+1 {{pure functions cannot access impure semantics}}
  c.fn = inner
  // expected-error@+1 {{pure functions cannot access impure semantics}}
  c.withF(inner)
  // expected-error@+1 {{pure functions cannot access impure semantics}}
  c.withF({ V() })
  let cl = { V() }
  // expected-error@+1 {{pure functions cannot access impure semantics}}
  c.withF(cl)

  // Test 'inout' and aliasing
}

class BadC1 {
  @pure func m() {}
  func m2() {
    @pure func v() -> V { return V() }
    func r() -> V { return V() }
    var s = S()
    var c = C()

    s.withF(v)
    c.withF(v)
    c.withF(r)
    // expected-error@+1 {{passing impure closure to function expecting a pure closure}}
    s.withF(r)

    s.fn = v
    c.fn = v
    c.fn = r
    // expected-error@+1 {{assigning impure closure to an pure closure}}
    s.fn = r

    var local = 42
    // expected-error@+1 {{escapable pure function cannot close over mutable variable 'local'}}
    @pure func noesc_v() -> V { _ = local; return V() }
    // No escape closures are okay:
    c.withF({ _ = local; return V() })
  }
}

@pure struct BadS1 {
  // expected-error@+1 {{'@pure' is redunant in this context}}
  @pure func m() {}
  func m2() {
    // expected-error@+1 {{'@pure' is redunant in this context}}
    @pure func l() {}
  }
}

@pure struct WeakS {
  // expected-error@+1 {{'weak' is not valid in '@pure' contexts}}
  weak var c : C?
}

@pure enum BadE1 {
  // expected-error@+1 {{'@pure' is redunant in this context}}
  @pure func m() {}
  func m2() {
    // expected-error@+1 {{'@pure' is redunant in this context}}
    @pure func l() {}
  }
}

var global : V = V()
@pure struct GTest {
  func foo(v : V) {
    // expected-error@+2 {{escapable pure function cannot close over mutable variable 'global'}}
    // expected-error@+1 {{pure functions cannot access shared mutable variables}}
    _ = global.neg()
    // expected-error@+2 {{escapable pure function cannot close over mutable variable 'global'}}
    // expected-error@+1 {{pure functions cannot mutate shared variables}}
    global.add(v)
  }
}

// expected-note@+1 {{change 'let' to 'var' to make it mutable}}
let constant : V = V()
@pure struct ConstTest {
  func foo(v : V) {
    _ = constant.neg()
    // expected-error@+1 {{cannot use mutating member on immutable value: 'constant' is a 'let' constant}}
    constant.add(v)
  }
}

@pure struct GeneralRefInValError {
  var c : C
  func foo() -> () -> V {
    // expected-error@+1 {{using impure closure in a context expecting a pure closure}}
    return c.fn
  }
}

@pure @impureBody func impBody(_ c : C) -> V {
  return c.iv
}
