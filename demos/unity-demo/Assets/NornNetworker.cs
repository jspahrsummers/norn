using MoonSharp.Interpreter;
using System.Collections.Concurrent;
using System.Diagnostics;

[MoonSharpUserData]
public sealed class NornNetworker
{
	private string _address;
	private static ConcurrentDictionary<string, NornNetworker> _networkersByAddress = new ConcurrentDictionary<string, NornNetworker>();

	private struct Message
	{
		public string sender;
		public string bytes;
	}

	private ConcurrentQueue<Message> _messageQueue = new ConcurrentQueue<Message>();

	[MoonSharpHidden]
	public NornNetworker(string address)
	{
		_address = address;

		bool success = _networkersByAddress.TryAdd(address, this);
		Debug.Assert(success);
	}

	public void Send(string dest, string bytes)
	{
		var networker = _networkersByAddress[dest];
		networker._messageQueue.Enqueue(new Message { sender = _address, bytes = bytes });
	}

	public DynValue Recv()
	{
		Message message;
		while (!_messageQueue.TryDequeue(out message)) { }

		return DynValue.NewTuple(DynValue.NewString(message.sender), DynValue.NewString(message.bytes));
	}
}