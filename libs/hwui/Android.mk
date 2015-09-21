LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk

hwui_src_files := \
    font/CacheTexture.cpp \
    font/Font.cpp \
    renderstate/Blend.cpp \
    renderstate/MeshState.cpp \
    renderstate/PixelBufferState.cpp \
    renderstate/RenderState.cpp \
    renderstate/Scissor.cpp \
    renderstate/Stencil.cpp \
    renderstate/TextureState.cpp \
    renderthread/CanvasContext.cpp \
    renderthread/DrawFrameTask.cpp \
    renderthread/EglManager.cpp \
    renderthread/RenderProxy.cpp \
    renderthread/RenderTask.cpp \
    renderthread/RenderThread.cpp \
    renderthread/TimeLord.cpp \
    thread/TaskManager.cpp \
    utils/Blur.cpp \
    utils/GLUtils.cpp \
    utils/LinearAllocator.cpp \
    utils/NinePatchImpl.cpp \
    utils/StringUtils.cpp \
    AmbientShadow.cpp \
    AnimationContext.cpp \
    Animator.cpp \
    AnimatorManager.cpp \
    AssetAtlas.cpp \
    Caches.cpp \
    CanvasState.cpp \
    ClipArea.cpp \
    DamageAccumulator.cpp \
    DeferredDisplayList.cpp \
    DeferredLayerUpdater.cpp \
    DisplayList.cpp \
    DisplayListCanvas.cpp \
    Dither.cpp \
    Extensions.cpp \
    FboCache.cpp \
    FontRenderer.cpp \
    FrameInfo.cpp \
    FrameInfoVisualizer.cpp \
    GammaFontRenderer.cpp \
    GlopBuilder.cpp \
    GradientCache.cpp \
    Image.cpp \
    Interpolator.cpp \
    JankTracker.cpp \
    Layer.cpp \
    LayerCache.cpp \
    LayerRenderer.cpp \
    Matrix.cpp \
    OpenGLRenderer.cpp \
    Patch.cpp \
    PatchCache.cpp \
    PathCache.cpp \
    PathTessellator.cpp \
    PixelBuffer.cpp \
    Program.cpp \
    ProgramCache.cpp \
    Properties.cpp \
    RenderBufferCache.cpp \
    RenderNode.cpp \
    RenderProperties.cpp \
    ResourceCache.cpp \
    ShadowTessellator.cpp \
    SkiaCanvas.cpp \
    SkiaCanvasProxy.cpp \
    SkiaShader.cpp \
    Snapshot.cpp \
    SpotShadow.cpp \
    TessellationCache.cpp \
    TextDropShadowCache.cpp \
    Texture.cpp \
    TextureCache.cpp \
    protos/hwui.proto

hwui_cflags := \
    -DEGL_EGLEXT_PROTOTYPES -DGL_GLEXT_PROTOTYPES \
    -DATRACE_TAG=ATRACE_TAG_VIEW -DLOG_TAG=\"OpenGLRenderer\" \
    -Wall -Wno-unused-parameter -Wunreachable-code \
    -ffast-math -O3 -Werror

ifndef HWUI_COMPILE_SYMBOLS
    hwui_cflags += -fvisibility=hidden
endif

ifdef HWUI_COMPILE_FOR_PERF
    # TODO: Non-arm?
    hwui_cflags += -fno-omit-frame-pointer -marm -mapcs
endif

# This has to be lazy-resolved because it depends on the LOCAL_MODULE_CLASS
# which varies depending on what is being built
define hwui_proto_include
$(call local-generated-sources-dir)/proto/$(LOCAL_PATH)
endef

hwui_c_includes += \
    external/skia/src/core

hwui_shared_libraries := \
    liblog \
    libcutils \
    libutils \
    libEGL \
    libGLESv2 \
    libskia \
    libui \
    libgui \
    libprotobuf-cpp-lite \

ifneq (false,$(ANDROID_ENABLE_RENDERSCRIPT))
    hwui_cflags += -DANDROID_ENABLE_RENDERSCRIPT
    hwui_shared_libraries += libRS libRScpp
    hwui_c_includes += \
        $(call intermediates-dir-for,STATIC_LIBRARIES,libRS,TARGET,) \
        frameworks/rs/cpp \
        frameworks/rs
endif


# ------------------------
# static library
# ------------------------

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := STATIC_LIBRARIES
LOCAL_MODULE := libhwui_static
LOCAL_SHARED_LIBRARIES := $(hwui_shared_libraries)
LOCAL_CFLAGS := $(hwui_cflags)
LOCAL_SRC_FILES := $(hwui_src_files)
LOCAL_C_INCLUDES := $(hwui_c_includes) $(call hwui_proto_include)
LOCAL_EXPORT_C_INCLUDE_DIRS := $(hwui_c_includes) $(call hwui_proto_include)

include $(BUILD_STATIC_LIBRARY)

# ------------------------
# shared library
# ------------------------

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE := libhwui
LOCAL_WHOLE_STATIC_LIBRARIES := libhwui_static
LOCAL_SHARED_LIBRARIES := $(hwui_shared_libraries)

include $(BUILD_SHARED_LIBRARY)

# ------------------------
# unit tests
# ------------------------

include $(CLEAR_VARS)

LOCAL_MODULE := hwui_unit_tests
LOCAL_MODULE_TAGS := tests
LOCAL_SHARED_LIBRARIES := $(hwui_shared_libraries)
LOCAL_STATIC_LIBRARIES := libhwui_static
LOCAL_CFLAGS := $(hwui_cflags)

LOCAL_SRC_FILES += \
    unit_tests/CanvasStateTests.cpp \
    unit_tests/ClipAreaTests.cpp \
    unit_tests/DamageAccumulatorTests.cpp \
    unit_tests/LinearAllocatorTests.cpp \
    unit_tests/StringUtilsTests.cpp

include $(BUILD_NATIVE_TEST)

# ------------------------
# test app
# ------------------------

include $(CLEAR_VARS)

LOCAL_MODULE_PATH := $(TARGET_OUT_DATA)/local/tmp
LOCAL_MODULE:= hwuitest
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MULTILIB := both
LOCAL_MODULE_STEM_32 := hwuitest
LOCAL_MODULE_STEM_64 := hwuitest64
LOCAL_SHARED_LIBRARIES := $(hwui_shared_libraries)
LOCAL_CFLAGS := $(hwui_cflags)

HWUI_NULL_GPU := false

ifeq (true, $(HWUI_NULL_GPU))
    # Only need to specify the includes if we are not linking against
    # libhwui_static as libhwui_static exports the appropriate includes
    LOCAL_C_INCLUDES := $(hwui_c_includes) $(call hwui_proto_include)

    LOCAL_SRC_FILES := \
        $(hwui_src_files) \
        tests/nullegl.cpp \
        tests/nullgles.cpp

    LOCAL_CFLAGS += -DHWUI_NULL_GPU
else
    LOCAL_WHOLE_STATIC_LIBRARIES := libhwui_static
endif

LOCAL_SRC_FILES += \
    tests/TestContext.cpp \
    tests/main.cpp

include $(BUILD_EXECUTABLE)
