# Version 1.2.0 (2017-09-07)

This release contains the following changes:

* The package requires Swift 4.
* `SipHasher` now has a method for appending slices of `UnsafeRawBufferPointer`s.
* In the supplied Xcode project, bundle identifiers have been updated. The new ones start with `org.attaswift.`.

Note that the URL for the package's Git repository has changed; please update your references.

# Version 1.1.2 (2017-05-05)

This release contains the following change:

* Removed all remaining use of @inline(__always) attributes.

# Version 1.1.1 (2017-02-07)

This release contains the following change:

* A Swift 3.1 compilation issue about SipHash's (ab)use of @inline(__always) was fixed.

# Version 1.1.0 (2016-11-23)

This release contains the following changes:

* `SipHasher` now supports appending optional values directly.
* The deployment target for Carthage and standalone builds was set back to iOS 8.0 and macOS 10.9,
  the earliest possible OS versions for Swift frameworks. This change does not affect CocoaPod builds, which 
  already had the same settings.

# Version 1.0.0 (2016-11-15)

This is the initial release of SipHash.
