//
//  LlamaMobileVD.h
//  LlamaMobileVD
//
//  Created by LlamaMobile Team on 2025-01-09.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LlamaMobileVDDistanceMetric) {
    LlamaMobileVDDistanceMetricL2 = 0,
    LlamaMobileVDDistanceMetricCosine = 1,
    LlamaMobileVDDistanceMetricDot = 2,
};

@interface LlamaMobileVDSearchResult : NSObject
@property (nonatomic, assign) uint64_t identifier;
@property (nonatomic, assign) float distance;
@end

@interface LlamaMobileVDVectorStore : NSObject

- (instancetype)initWithDimension:(NSUInteger)dimension metric:(LlamaMobileVDDistanceMetric)metric;

- (BOOL)addIdentifier:(uint64_t)identifier vector:(const float *)vector error:(NSError **)error;
- (BOOL)removeIdentifier:(uint64_t)identifier removed:(BOOL *)removed error:(NSError **)error;
- (BOOL)getVectorForIdentifier:(uint64_t)identifier vector:(float *)vector vectorSize:(NSUInteger)vectorSize error:(NSError **)error;
- (BOOL)updateIdentifier:(uint64_t)identifier vector:(const float *)vector error:(NSError **)error;
- (nullable NSArray<LlamaMobileVDSearchResult *> *)searchVector:(const float *)query k:(NSUInteger)k error:(NSError **)error;
- (NSUInteger)size:(NSError **)error;
- (NSUInteger)dimension:(NSError **)error;
- (LlamaMobileVDDistanceMetric)metric:(NSError **)error;
- (BOOL)containsIdentifier:(uint64_t)identifier contains:(BOOL *)contains error:(NSError **)error;
- (BOOL)reserveCapacity:(NSUInteger)capacity error:(NSError **)error;
- (BOOL)clear:(NSError **)error;

@end

@interface LlamaMobileVDHNSWIndex : NSObject

- (instancetype)initWithDimension:(NSUInteger)dimension metric:(LlamaMobileVDDistanceMetric)metric maxElements:(NSUInteger)maxElements;
- (instancetype)initWithDimension:(NSUInteger)dimension metric:(LlamaMobileVDDistanceMetric)metric maxElements:(NSUInteger)maxElements M:(NSUInteger)M efConstruction:(NSUInteger)efConstruction seed:(uint32_t)seed;

- (BOOL)addIdentifier:(uint64_t)identifier vector:(const float *)vector error:(NSError **)error;
- (nullable NSArray<LlamaMobileVDSearchResult *> *)searchVector:(const float *)query k:(NSUInteger)k error:(NSError **)error;
- (BOOL)setEfSearch:(NSUInteger)efSearch error:(NSError **)error;
- (NSUInteger)efSearch:(NSError **)error;
- (NSUInteger)size:(NSError **)error;
- (NSUInteger)dimension:(NSError **)error;
- (NSUInteger)capacity:(NSError **)error;
- (BOOL)containsIdentifier:(uint64_t)identifier contains:(BOOL *)contains error:(NSError **)error;
- (BOOL)getVectorForIdentifier:(uint64_t)identifier vector:(float *)vector vectorSize:(NSUInteger)vectorSize error:(NSError **)error;
- (BOOL)saveToFile:(NSString *)filename error:(NSError **)error;
+ (nullable instancetype)loadFromFile:(NSString *)filename error:(NSError **)error;

@end

@interface LlamaMobileVDMMapVectorStoreBuilder : NSObject

- (instancetype)initWithDimension:(NSUInteger)dimension metric:(LlamaMobileVDDistanceMetric)metric;

- (BOOL)addIdentifier:(uint64_t)identifier vector:(const float *)vector error:(NSError **)error;
- (BOOL)reserveCapacity:(NSUInteger)capacity error:(NSError **)error;
- (BOOL)saveToFile:(NSString *)filename error:(NSError **)error;
- (NSUInteger)size:(NSError **)error;
- (NSUInteger)dimension:(NSError **)error;

@end

@interface LlamaMobileVDMMapVectorStore : NSObject

- (BOOL)getVectorForIdentifier:(uint64_t)identifier vector:(float *)vector vectorSize:(NSUInteger)vectorSize error:(NSError **)error;
- (BOOL)containsIdentifier:(uint64_t)identifier contains:(BOOL *)contains error:(NSError **)error;
- (nullable NSArray<LlamaMobileVDSearchResult *> *)searchVector:(const float *)query k:(NSUInteger)k error:(NSError **)error;
- (NSUInteger)size:(NSError **)error;
- (NSUInteger)dimension:(NSError **)error;
- (LlamaMobileVDDistanceMetric)metric:(NSError **)error;

+ (nullable instancetype)openFromFile:(NSString *)filename error:(NSError **)error;

@end

@interface LlamaMobileVD : NSObject

+ (NSString *)version;
+ (NSInteger)versionMajor;
+ (NSInteger)versionMinor;
+ (NSInteger)versionPatch;

@end

NS_ASSUME_NONNULL_END
