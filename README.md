# SafeCache

This is package purpose is to offer a thread safe cache service for swift projects.
It is based on the article of **John Sundell** on how to implement a Cache service in swift while leveraging the power of NSCache. [Caching By Sundell](https://www.swiftbysundell.com/articles/caching-in-swift/)
The implementation contains a `actor` wrapper around NSCache to make it compatible with the new Async/Await concurrency of Swift.
It also offers a way to persist data on disk in some cases.

# What

- [x] Caching
- [x] Uses of Apple's new structured concurrency (Async/Await)
- [x] Disk Persistency 
- [x] Use the power of Generics
- [x] Tested

## Getting Started
* [Installation](#installation)
* [Create a Cache](#create-a-cache)
* [Actions](#actions)

# Installation

`SafeCache` is installed via the official [Swift Package Manager](https://swift.org/package-manager/).  

Select `Xcode`>`File`> `Swift Packages`>`Add Package Dependency...`  
and add `https://github.com/lukacs-m/SafeCache`.


### Create a Cache

To create an instance of **SafeCache** it is very easy.
You just need to instanciate it with a **Key/Value** type and voila you can now start a caching festival. 
The following implementation has a type `String` for the keys and `CachedObject` as the value type saved in this instance of cache. 

```swift
// Default
struct CachedObject {
 let text = "I'm the cached object"
}

let cacheClient = SafeCache<String, CachedObject>() 
```
Of course the key and value type combo could be completly different.

## Actions

### Add element to cache 

```swift
    await cacheClient.insert(ElementToAdd, forKey: key)
```

### Get element for key from cache

```swift
    let value = await cacheClient.value(forKey: key)
```

### Remove one element of cahche

```swift
    await cacheClient.removeValue(forKey: key)
```

### Remove all element of cache

```swift
    await cacheClient.removeAll()
```
