# 小凌派-RK2206开发板OpenHarmonyOS内核开发-KV存储

## 实验内容

本例程演示如何在小凌派-RK2206开发板上使用鸿蒙LiteOS-M内核接口，进行KV存储开发。

例程：

（1）创建两个线程，一个负责写入KV存储，一个负责读取KV存储；

（2）每1秒进行1次读写操作；

![小凌派-RK2206开发板](/vendor/lockzhiner/rk2206/docs/figures/lockzhiner-rk2206.jpg)

## 程序设计

在本章节中，我们将了解OpenHarmonyKV存储接口，如文件如何获取数据、设置数据、删除数据和清除缓存。

### API分析

#### 头文件

```shell
//utils/native/lite/include/kv_store.h
```

#### UtilsGetValue()

```c
int UtilsGetValue(const char* key, char* value, unsigned int len);
```

**描述：**

从文件系统或缓存中获取与指定键匹配的值。

**参数：**

|名字|描述|
|:--|:------|
| key | 键值 |
| value | 获取数据 |
| len | 数据长度 |

**返回值：**

|返回值|描述|
|:--|:------|
| 0 | 成功 |
| 其它 | 见utils/native/lite/include/ohos_errno.h |

#### UtilsSetValue()

```c
int UtilsSetValue(const char* key, const char* value);
```

**描述：**

添加或更新与文件系统或缓存中的指定键匹配的值。

**参数：**

|名字|描述|
|:--|:------|
| key | 键值 |
| value | 写入数据 |

**返回值：**
|返回值|描述|
|:--|:------|
| 0 | 成功 |
| 其它 | 见utils/native/lite/include/ohos_errno.h |

#### UtilsDeleteValue()

```c
int UtilsDeleteValue(const char* key);
```

**描述：**

从文件系统或缓存中删除与指定键匹配的值。

**参数：**

|名字|描述|
|:--|:------|
| key | 键值 |

**返回值：**
|返回值|描述|
|:--|:------|
| 0 | 成功 |
| 其它 | 见utils/native/lite/include/ohos_errno.h |

#### ClearKVCache()

```c
int ClearKVCache(void);
```

**描述：**

从缓存中清除所有键值对。

**返回值：**
|返回值|描述|
|:--|:------|
| 0 | 成功 |
| 其它 | 见utils/native/lite/include/ohos_errno.h |

### 软件设计

**主要代码分析**

在kv_store_example函数中通过LOS_TaskCreate函数创建两个线程：kv_store_write_thread、kv_store_read_thread。

```c
void kv_store_example()
{
    unsigned int thread_id1;
    unsigned int thread_id2;
    TSK_INIT_PARAM_S task1 = {0};
    TSK_INIT_PARAM_S task2 = {0};
    unsigned int ret = LOS_OK;

    task1.pfnTaskEntry = (TSK_ENTRY_FUNC)kv_store_write_thread;
    task1.uwStackSize = 1024 * 10;
    task1.pcName = "kv_store_write_thread";
    task1.usTaskPrio = 25;
    ret = LOS_TaskCreate(&thread_id1, &task1);
    if (ret != LOS_OK)
    {
        printf("Falied to create kv_store_write_thread ret:0x%x\n", ret);
        return;
    }

    task2.pfnTaskEntry = (TSK_ENTRY_FUNC)kv_store_read_thread;
    task2.uwStackSize = 1024 * 10;
    task2.pcName = "kv_store_read_thread";
    task2.usTaskPrio = 25;
    ret = LOS_TaskCreate(&thread_id2, &task2);
    if (ret != LOS_OK)
    {
        printf("Falied to create kv_store_read_thread ret:0x%x\n", ret);
        return;
    }
}

APP_FEATURE_INIT(kv_store_example);
```

kv_store_write_thread线程负责创建/更新KV存储，每1秒写入一段内容，重复以上流程。

```c
void kv_store_write_thread()
{
    int ret = 0;
    char defValue[50] = {0};
    int current = 0;

    while (1)
    {
        snprintf(defValue, sizeof(defValue), "test value %d.", current);
        int ret = UtilsSetValue(key, defValue);
        if (ret < 0)
        {
            printf("[error] %d\r\n", ret);
        }
        else
        {
            printf("[write] write success\r\n");
        }

        current++;
        LOS_Msleep(1000);
    }
}
```

kv_store_read_thread线程负责读取KV存储，每1秒读取一段内容，重复以上流程。

```c
void kv_store_read_thread()
{
    int ret = 0;
    char value1[50] = {0};

    while (1)
    {
        ret = UtilsGetValue(key, value1, sizeof(value1));
        if (ret < 0)
        {
            printf("[error] %d\r\n", ret);
        }
        else
        {
            printf("[read] key: %s value:%s\r\n", key, value1);
        }

        LOS_Msleep(1000);
    }
}
```

## 编译调试

### 修改 BUILD.gn 文件

修改 `vendor/lockzhiner/rk2206/sample` 路径下 BUILD.gn 文件，指定 `a10_kv_store` 参与编译。

```r
"./a10_kv_store:kv_store_example",
```

修改 `device/rockchip/rk2206/sdk_liteos` 路径下 Makefile 文件，添加 `-lkv_store_example` 参与编译。

```r
app_LIBS = -lkv_store_example
```

### 运行结果

示例代码编译烧录代码后，按下开发板的RESET按键，通过串口助手查看日志。

```r
HalFileInit: Flash Init Successful!
[write] write success
[read] key: key_sample value:test value 0.
[write] write success
[read] key: key_sample value:test value 1.
[write] write success
[read] key: key_sample value:test value 2.
[write] write success
[read] key: key_sample value:test value 3.
```
