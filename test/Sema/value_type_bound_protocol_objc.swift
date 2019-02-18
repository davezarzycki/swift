// RUN: %target-typecheck-verify-swift -enable-objc-interop

@objc protocol Bad_ObjC : !class {} // expected-error {{cannot inherit from both class-bound and pure protocols}}
