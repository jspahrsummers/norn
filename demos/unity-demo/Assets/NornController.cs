using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MoonSharp.Interpreter;
using MoonSharp.Interpreter.Loaders;

public sealed class NornController : MonoBehaviour
{
	// Start is called before the first frame update
	void Start()
	{
		var scriptLoader = new FileSystemScriptLoader();
		scriptLoader.ModulePaths = new string[] { "lua_modules/share/lua/5.2/?.lua" };

		var script = new Script();
		script.Options.ScriptLoader = scriptLoader;

		var result = script.DoString("require('norn.demo')");
		Debug.Log(result);
	}
}
