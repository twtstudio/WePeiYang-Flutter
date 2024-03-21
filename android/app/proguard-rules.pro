-dontoptimize
-dontskipnonpubliclibraryclassmembers
-keepattributes Exceptions,InnerClasses,Signature,SourceFile,LineNumberTable

-keep public class com.twt.service.R$*{
    public static final int *;
}

# 不混淆open sdk, 避免有些调用（如js）找不到类或方法
-keep class com.tencent.connect.** {*;}
-keep class com.tencent.open.** {*;}
-keep class com.tencent.tauth.** {*;}

# 定位
-keep class com.amap.api.location.**{*;}
-keep class com.amap.api.fence.**{*;}
-keep class com.autonavi.aps.amapapi.model.**{*;}

# 个推
-dontwarn com.igexin.**
-keep class com.igexin.** { *; }
-keep class org.json.** { *; }

# 友盟
# https://blog.csdn.net/qq_22007319/article/details/121997354
# 在 umeng_common_sdk 中 新建 proguard-rules.pro 文件，写入下面内容
#    -keep class com.umeng.** {*;}
#
#    -keepclassmembers class * {
#       public <init> (org.json.JSONObject);
#    }
#
#    -keepclassmembers enum * {
#        public static **[] values();
#        public static ** valueOf(java.lang.String);
#    }
# 最后在 build.gradle 中加入：
#    consumerProguardFiles 'proguard-rules.pro'

# 友盟
-keep class com.umeng.** {*;}
-keep class com.uc.** { *; }
-keep class com.efs.** { *; }
-keepclassmembers class * {
   public <init> (org.json.JSONObject);
}
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

-dontwarn com.yalantis.ucrop.**
-keep class com.yalantis.ucrop.** { *; }
-keep interface com.yalantis.ucrop.** { *; }
-keep class androidx.appcompat.** { *; }
-keepclassmembers class * {
   public <init> (com.yalantis.ucrop.**);
}

# 据个推客服说，不用管这个
## 华为
#-keep class com.huawei.hianalytics.**{*;}
#-keep class com.huawei.updatesdk.**{*;}
#-keep class com.huawei.hms.**{*;}

# 输出所有规则叠加后的混淆规则
-printconfiguration ./build/outputs/mapping/full-config.txt

# 输出seeds.txt文件
-printseeds ./build/outputs/mapping/seeds.txt

# 输出usage.txt文件
-printusage ./build/outputs/mapping/usage.txt

# 输出mapping.txt文件
-printmapping ./build/outputs/mapping/mapping.txt
