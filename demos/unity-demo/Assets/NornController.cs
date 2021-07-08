using System;
using UnityEngine;
using MoonSharp.Interpreter;
using MoonSharp.Interpreter.Loaders;

public sealed class NornController : MonoBehaviour
{
	// Start is called before the first frame update
	void Start()
	{
		UserData.RegisterAssembly();

		var scriptLoader = new FileSystemScriptLoader();
		scriptLoader.ModulePaths = new string[] { "lua_modules/share/lua/5.2/?.lua" };

		var script = new Script();
		script.Options.ScriptLoader = scriptLoader;
		script.Globals["crypto"] = NornCrypto.ModuleTable(script);
		script.Globals["create_networker"] = (Func<string, object>)(address => new NornNetworker(address));

		var mainText = Resources.Load<TextAsset>("main.lua");
		var result = script.DoString(mainText.text);
		Debug.Log(result);
	}
}
