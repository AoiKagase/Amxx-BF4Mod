// Offline test host for the adjacent AMX Mod X Pawn VM (not a GoldSrc server).
// CompuPhase VM sources retain their original license in the dependency checkout.
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>
#include <cmath>
#include "amx.h"

static cell AMX_NATIVE_CALL Check(AMX* amx, cell* params)
{
    if (!params[1]) {
        std::fprintf(stderr, "ASSERT FAILED: case %d\n", static_cast<int>(params[2]));
        amx_RaiseError(amx, AMX_ERR_NATIVE);
    }
    return params[1];
}

static float AsFloat(cell value) { float result; std::memcpy(&result, &value, sizeof result); return result; }
static cell AsCell(float value) { cell result; std::memcpy(&result, &value, sizeof result); return result; }
static cell AMX_NATIVE_CALL FloatAdd(AMX*, cell* p) { return AsCell(AsFloat(p[1]) + AsFloat(p[2])); }
static cell AMX_NATIVE_CALL FloatSub(AMX*, cell* p) { return AsCell(AsFloat(p[1]) - AsFloat(p[2])); }
static cell AMX_NATIVE_CALL FloatMul(AMX*, cell* p) { return AsCell(AsFloat(p[1]) * AsFloat(p[2])); }
static cell AMX_NATIVE_CALL FloatDiv(AMX*, cell* p) { return AsCell(AsFloat(p[1]) / AsFloat(p[2])); }
static cell AMX_NATIVE_CALL FloatCmp(AMX*, cell* p) { float a=AsFloat(p[1]), b=AsFloat(p[2]); return a>b ? 1 : (a<b ? -1 : 0); }

int main(int argc, char** argv)
{
    if (argc != 2) return 2;
    FILE* file = std::fopen(argv[1], "rb");
    if (!file) return 2;
    std::fseek(file, 0, SEEK_END);
    long size = std::ftell(file);
    std::rewind(file);
    std::vector<unsigned char> image(static_cast<size_t>(size));
    bool read = std::fread(image.data(), 1, image.size(), file) == image.size();
    std::fclose(file);
    if (!read || image.size() < sizeof(AMX_HEADER)) return 2;
    const AMX_HEADER header = *reinterpret_cast<const AMX_HEADER*>(image.data());
    if (header.stp <= 0 || header.stp > 64 * 1024 * 1024) return 2;
    image.resize(static_cast<size_t>(header.stp) + 4096);
    AMX amx = {};
    int error = amx_Init(&amx, image.data());
    if (error) { std::fprintf(stderr, "amx_Init=%d\n", error); return 1; }
    AMX_NATIVE_INFO natives[] = {{"check", Check}, {"floatadd", FloatAdd}, {"floatsub", FloatSub},
        {"floatmul", FloatMul}, {"floatdiv", FloatDiv}, {"floatcmp", FloatCmp}, {nullptr, nullptr}};
    error = amx_Register(&amx, natives, -1);
    if (error) {
        std::fprintf(stderr, "Unregistered native: %d (tests may only call explicitly supplied natives)\n", error);
        return 1;
    }
    cell result = 0;
    error = amx_Exec(&amx, &result, AMX_EXEC_MAIN);
    amx_Cleanup(&amx);
    if (error) { std::fprintf(stderr, "amx_Exec=%d\n", error); return 1; }
    std::printf("Pawn assertions passed; result=%d\n", static_cast<int>(result));
    return 0;
}
