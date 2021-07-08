using MoonSharp.Interpreter;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;

public static class NornCrypto
{
	private static Int32 _privateKeyNum = -1;

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

	private static string sign(DynValue privateKey, IEnumerable<DynValue> data)
	{
		Debug.Assert(privateKey.Number < 0);
		return String.Join<string>("*", from d in data.Prepend(privateKey) select d.CastToString());
	}

	public static DynValue SignCallback(ScriptExecutionContext ctx, CallbackArguments cbArgs)
	{
		var args = cbArgs.GetArray();
		var privateKey = args[0];
		return DynValue.NewString(sign(privateKey, args.Skip(1)));
	}

	public static DynValue VerifyCallback(ScriptExecutionContext ctx, CallbackArguments cbArgs)
	{
		var args = cbArgs.GetArray();

		var privateKey = args[0].Number < 0 ? args[0] : DynValue.NewNumber(-args[0].Number);
		var expected = sign(privateKey, args.Skip(2));

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
