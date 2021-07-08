using MoonSharp.Interpreter;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;

public static class NornCrypto
{
	private static Int32 _privateKeyNum = -1;

	public static Table ModuleTable(Script script)
	{
		var crypto = new Table(script);
		crypto["hash"] = new CallbackFunction(HashCallback);
		crypto["generate_private_key"] = (Func<DynValue>)(GeneratePrivateKey);
		crypto["public_key"] = (Func<DynValue, DynValue>)(PublicKey);
		crypto["sign"] = new CallbackFunction(SignCallback);
		crypto["verify"] = new CallbackFunction(VerifyCallback);
		crypto["serialize_public_key"] = (Func<DynValue, string>)(SerializePublicKey);
		crypto["deserialize_public_key"] = (Func<string, DynValue>)(DeserializePublicKey);
		return crypto;
	}

	public static DynValue HashCallback(ScriptExecutionContext ctx, CallbackArguments cbArgs)
	{
		var args = cbArgs.GetArray();
		var hash = String.Join<string>("_", from a in args select a.CastToString());
		return DynValue.NewString(hash);
	}

	public static DynValue GeneratePrivateKey()
	{
		return DynValue.NewNumber(Interlocked.Decrement(ref _privateKeyNum));
	}

	public static DynValue PublicKey(DynValue publicOrPrivateKey)
	{
		var num = publicOrPrivateKey.Number;
		if (num < 0)
		{
			return DynValue.NewNumber(-num);
		}
		else
		{
			return publicOrPrivateKey;
		}
	}

	private static string Sign(DynValue privateKey, IEnumerable<DynValue> data)
	{
		Debug.Assert(privateKey.Number < 0);
		return String.Join<string>("*", from d in data.Prepend(privateKey) select d.CastToString());
	}

	public static DynValue SignCallback(ScriptExecutionContext ctx, CallbackArguments cbArgs)
	{
		var args = cbArgs.GetArray();
		var privateKey = args[0];
		return DynValue.NewString(Sign(privateKey, args.Skip(1)));
	}

	public static DynValue VerifyCallback(ScriptExecutionContext ctx, CallbackArguments cbArgs)
	{
		var args = cbArgs.GetArray();

		var privateKey = args[0].Number < 0 ? args[0] : DynValue.NewNumber(-args[0].Number);
		var expected = Sign(privateKey, args.Skip(2));

		return DynValue.NewBoolean(args[1].String == expected);
	}

	public static string SerializePublicKey(DynValue publicKey)
	{
		return publicKey.Number.ToString();
	}

	public static DynValue DeserializePublicKey(string publicKeyString)
	{
		return DynValue.NewNumber(Double.Parse(publicKeyString));
	}
}
