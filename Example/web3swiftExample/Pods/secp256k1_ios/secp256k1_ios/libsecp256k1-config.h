//
//  libsecp256k1-config.h
//  secp256k1_ios
//
//  Created by Alexander Vlasov on 27.02.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

#ifndef libsecp256k1_config_h
#define libsecp256k1_config_h

#undef USE_NUM_GMP
#define USE_NUM_NONE 1
#define USE_FIELD_INV_BUILTIN 1
#define USE_SCALAR_INV_BUILTIN 1

#define HAVE_BUILTIN_EXPECT 1
//#define USE_ECMULT_STATIC_PRECOMPUTATION 1
#define ENABLE_MODULE_RECOVERY 1

#define STDC_HEADERS 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_SYS_STAT_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRING_H 1
#define HAVE_MEMORY_H 1
#define HAVE_STRINGS_H 1
#define HAVE_INTTYPES_H 1
#define HAVE_STDINT_H 1
#define HAVE_UNISTD_H 1
#define HAVE_DLFCN_H 1

#if defined(__LP64__)
#if defined(__SIZEOF_INT128__)
#define HAVE___INT128 1
#endif
#define USE_FIELD_5X52 1
#define USE_SCALAR_4X64 1

#else
#define USE_FIELD_10X26 1
#define USE_SCALAR_8X32 1
#endif


#endif /* libsecp256k1_config_h */
