THIRD_PARTY_PATH := $(call my-dir)

GLSLANG_LOCAL_PATH := $(THIRD_PARTY_PATH)/glslang
LOCAL_PATH := $(GLSLANG_LOCAL_PATH)

GLSLANG_OS_FLAGS := -DGLSLANG_OSINCLUDE_UNIX

include $(CLEAR_VARS)
LOCAL_MODULE:=SPIRV
LOCAL_CXXFLAGS:=-std=c++11 -fno-exceptions -fno-rtti $(GLSLANG_OS_FLAGS)
LOCAL_EXPORT_C_INCLUDES:=$(GLSLANG_LOCAL_PATH)
LOCAL_SRC_FILES:= \
	SPIRV/GlslangToSpv.cpp \
	SPIRV/InReadableOrder.cpp \
	SPIRV/SPVRemapper.cpp \
	SPIRV/SpvBuilder.cpp \
	SPIRV/disassemble.cpp \
	SPIRV/doc.cpp

LOCAL_C_INCLUDES:=$(GLSLANG_LOCAL_PATH) $(GLSLANG_LOCAL_PATH)/glslang/SPIRV
LOCAL_EXPORT_C_INCLUDES:=$(GLSLANG_LOCAL_PATH)/glslang/SPIRV
include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE:=OSDependent
LOCAL_CXXFLAGS:=-std=c++11 -fno-exceptions -fno-rtti $(GLSLANG_OS_FLAGS)
LOCAL_EXPORT_C_INCLUDES:=$(GLSLANG_LOCAL_PATH)
LOCAL_SRC_FILES:=glslang/OSDependent/Unix/ossource.cpp
LOCAL_C_INCLUDES:=$(GLSLANG_LOCAL_PATH) $(GLSLANG_LOCAL_PATH)/glslang/OSDependent/Unix/
LOCAL_EXPORT_C_INCLUDES:=$(GLSLANG_LOCAL_PATH)/glslang/OSDependent/Unix/
include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE:=OGLCompiler
LOCAL_CXXFLAGS:=-std=c++11 -fno-exceptions -fno-rtti $(GLSLANG_OS_FLAGS)
LOCAL_EXPORT_C_INCLUDES:=$(GLSLANG_LOCAL_PATH)
LOCAL_SRC_FILES:=OGLCompilersDLL/InitializeDll.cpp
LOCAL_C_INCLUDES:=$(GLSLANG_LOCAL_PATH)/OGLCompiler
LOCAL_STATIC_LIBRARIES:=OSDependent
include $(BUILD_STATIC_LIBRARY)


# Build Glslang's HLSL parser library.
include $(CLEAR_VARS)
LOCAL_MODULE:=HLSL
LOCAL_CXXFLAGS:=-std=c++11 -fno-exceptions -fno-rtti
LOCAL_SRC_FILES:= \
		hlsl/hlslGrammar.cpp \
		hlsl/hlslParseHelper.cpp \
		hlsl/hlslScanContext.cpp
LOCAL_C_INCLUDES:=$(GLSLANG_LOCAL_PATH) \
	$(GLSLANG_LOCAL_PATH)/hlsl
include $(BUILD_STATIC_LIBRARY)


include $(CLEAR_VARS)

GLSLANG_OUT_PATH=$(abspath $(TARGET_OUT))

LOCAL_MODULE:=glslang
LOCAL_CXXFLAGS:=-std=c++11 -fno-exceptions -fno-rtti $(GLSLANG_OS_FLAGS)
LOCAL_EXPORT_C_INCLUDES:=$(GLSLANG_LOCAL_PATH)

LOCAL_SRC_FILES:= \
		glslang/GenericCodeGen/CodeGen.cpp \
		glslang/GenericCodeGen/Link.cpp \
		glslang/MachineIndependent/Constant.cpp \
		glslang/MachineIndependent/glslang_tab.cpp \
		glslang/MachineIndependent/InfoSink.cpp \
		glslang/MachineIndependent/Initialize.cpp \
		glslang/MachineIndependent/Intermediate.cpp \
		glslang/MachineIndependent/intermOut.cpp \
		glslang/MachineIndependent/IntermTraverse.cpp \
		glslang/MachineIndependent/limits.cpp \
		glslang/MachineIndependent/linkValidate.cpp \
		glslang/MachineIndependent/parseConst.cpp \
		glslang/MachineIndependent/ParseHelper.cpp \
		glslang/MachineIndependent/PoolAlloc.cpp \
		glslang/MachineIndependent/reflection.cpp \
		glslang/MachineIndependent/RemoveTree.cpp \
		glslang/MachineIndependent/Scan.cpp \
		glslang/MachineIndependent/ShaderLang.cpp \
		glslang/MachineIndependent/SymbolTable.cpp \
		glslang/MachineIndependent/Versions.cpp \
		glslang/MachineIndependent/preprocessor/PpAtom.cpp \
		glslang/MachineIndependent/preprocessor/PpContext.cpp \
		glslang/MachineIndependent/preprocessor/Pp.cpp \
		glslang/MachineIndependent/preprocessor/PpMemory.cpp \
		glslang/MachineIndependent/preprocessor/PpScanner.cpp \
		glslang/MachineIndependent/preprocessor/PpSymbols.cpp \
		glslang/MachineIndependent/preprocessor/PpTokens.cpp

LOCAL_C_INCLUDES:=$(GLSLANG_LOCAL_PATH) \
	$(GLSLANG_LOCAL_PATH)/glslang/MachineIndependent \
	$(GLSLANG_OUT_PATH)
LOCAL_STATIC_LIBRARIES:=OSDependent OGLCompiler SPIRV HLSL
include $(BUILD_STATIC_LIBRARY)


SPVTOOLS_LOCAL_PATH := $(THIRD_PARTY_PATH)/spirv-tools
LOCAL_PATH := $(SPVTOOLS_LOCAL_PATH)
SPVTOOLS_OUT_PATH=$(abspath $(TARGET_OUT))

define gen_spvtools_grammar_tables
$(call generate-file-dir,$(1)/core.insts.inc)
$(1)/core.insts.inc $(1)/operand.kinds.inc $(1)/glsl.std.450.insts.inc $(1)/opencl.std.insts.inc: \
        $(SPVTOOLS_LOCAL_PATH)/utils/generate_grammar_tables.py \
        $(SPVTOOLS_LOCAL_PATH)/source/spirv.core.grammar.json \
        $(SPVTOOLS_LOCAL_PATH)/source/extinst.glsl.std.450.grammar.json \
        $(SPVTOOLS_LOCAL_PATH)/source/extinst.opencl.std.grammar.json
		@$(HOST_PYTHON) $(SPVTOOLS_LOCAL_PATH)/utils/generate_grammar_tables.py \
		                --spirv-core-grammar=$(SPVTOOLS_LOCAL_PATH)/source/spirv.core.grammar.json \
		                --extinst-glsl-grammar=$(SPVTOOLS_LOCAL_PATH)/source/extinst.glsl.std.450.grammar.json \
		                --extinst-opencl-grammar=$(SPVTOOLS_LOCAL_PATH)/source/extinst.opencl.std.grammar.json \
		                --core-insts-output=$(1)/core.insts.inc \
		                --glsl-insts-output=$(1)/glsl.std.450.insts.inc \
		                --opencl-insts-output=$(1)/opencl.std.insts.inc \
		                --operand-kinds-output=$(1)/operand.kinds.inc
		@echo "[$(TARGET_ARCH_ABI)] Grammar        : instructions & operands <= grammar JSON files"
$(SPVTOOLS_LOCAL_PATH)/source/opcode.cpp: $(1)/core.insts.inc
$(SPVTOOLS_LOCAL_PATH)/source/operand.cpp: $(1)/operand.kinds.inc
$(SPVTOOLS_LOCAL_PATH)/source/ext_inst.cpp: $(1)/glsl.std.450.insts.inc $(1)/opencl.std.insts.inc
endef
$(eval $(call gen_spvtools_grammar_tables,$(SPVTOOLS_OUT_PATH)))

include $(CLEAR_VARS)
LOCAL_MODULE := SPIRV-Tools
LOCAL_C_INCLUDES := \
		$(SPVTOOLS_LOCAL_PATH)/include \
		$(SPVTOOLS_LOCAL_PATH)/source \
		$(SPVTOOLS_OUT_PATH)
LOCAL_EXPORT_C_INCLUDES := \
		$(SPVTOOLS_LOCAL_PATH)/include
LOCAL_CXXFLAGS:=-std=c++11 -fno-exceptions -fno-rtti
LOCAL_SRC_FILES:= \
		source/assembly_grammar.cpp \
		source/binary.cpp \
		source/diagnostic.cpp \
		source/disassemble.cpp \
		source/ext_inst.cpp \
		source/instruction.cpp \
		source/opcode.cpp \
		source/operand.cpp \
		source/print.cpp \
		source/spirv_endian.cpp \
		source/spirv_target_env.cpp \
		source/table.cpp \
		source/text.cpp \
		source/text_handler.cpp \
		source/validate.cpp \
		source/validate_cfg.cpp \
		source/validate_id.cpp \
		source/validate_instruction.cpp \
		source/validate_layout.cpp \
		source/validate_ssa.cpp \
		source/validate_types.cpp
include $(BUILD_STATIC_LIBRARY)
