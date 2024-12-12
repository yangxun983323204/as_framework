#pragma once

#include "CoreMinimal.h"
#include "FunctionLibraryMath.generated.h"

class UFunctionLibraryMath;
typedef UFunctionLibraryMath FLM;

/**
 * 数学扩展函数库
 */
UCLASS()
class UFunctionLibraryMath : public UObject
{
	GENERATED_BODY()
public:
	UFUNCTION(BlueprintCallable)
	static FColor FromHex(const FString& HexString);

    UFUNCTION(BlueprintCallable, BlueprintPure)
    static FString ToASCII(const int& Code);
};
