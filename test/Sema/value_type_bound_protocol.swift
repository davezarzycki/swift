// RUN: %target-typecheck-verify-swift -disable-objc-interop

protocol P : !class {}
struct S : P {}
enum E : P {}
class C : P {} // expected-error{{class type 'C' cannot conform to pure protocol 'P'}}

protocol Bad_Double : !class, !class {} // expected-error {{redundant '!class' requirement}}
protocol Bad_Late : P, !class {} // expected-error {{'!class' must come first in the requirement list}}

protocol Pc : class {}
protocol Bad_Conflict : P, Pc {} // expected-error {{cannot inherit from both class-bound and pure protocols}}
