using MoonSharp.Interpreter;

public static class NornCrypto
{
	public static DynValue HashCallback(ScriptExecutionContext ctx, CallbackArguments cbArgs)
	{
		var args = cbArgs.GetArray();

		return DynValue.Nil;
	}

	public static DynValue GeneratePrivateKey()
	{
		return DynValue.Nil;
	}

	public static DynValue PublicKey(DynValue publicOrPrivateKey)
	{
		return DynValue.Nil;
	}

	public static DynValue SignCallback(ScriptExecutionContext ctx, CallbackArguments cbArgs)
	{
		var args = cbArgs.GetArray();
		var privateKey = args[0];

		return DynValue.Nil;
	}

	public static DynValue VerifyCallback(ScriptExecutionContext ctx, CallbackArguments cbArgs)
	{
		var args = cbArgs.GetArray();
		var publicOrPrivateKey = args[0];
		var signature = args[1];

		return DynValue.Nil;
	}

	public static string SerializePublicKey(DynValue publicKey)
	{
		return null;
	}

	public static DynValue DeserializePublicKey(string publicKeyString)
	{
		return DynValue.Nil;
	}
}
