using MoonSharp.Interpreter;
using System;
using System.Linq;
using UnityEngine;

// MoonSharp does not ordinarily populate the io module under Unity. Norn uses io.stderr only, to write log messages, so let's connect it to Unity logging.
public static class NornIO
{
	public static Table ModuleTable(Script script)
	{
		var stderr = new Table(script);
		stderr["write"] = new CallbackFunction(Write);

		var io = new Table(script);
		io["stderr"] = stderr;

		return io;
	}

	public static DynValue Write(ScriptExecutionContext ctx, CallbackArguments cbArgs)
	{
		var args = cbArgs.GetArray();
		var message = String.Join("", from a in args.Skip(1) select a.CastToString());
		Debug.Log(message);
		return DynValue.Void;
	}
}
