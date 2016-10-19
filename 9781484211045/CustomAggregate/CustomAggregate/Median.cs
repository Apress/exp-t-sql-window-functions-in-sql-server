using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Collections.Generic;

[Serializable]
[Microsoft.SqlServer.Server.SqlUserDefinedAggregate(
    Format.UserDefined,
    IsInvariantToDuplicates = false,
    IsInvariantToNulls = false,
    IsInvariantToOrder = false,
    MaxByteSize=8000
)]
public struct Median : IBinarySerialize
{
    private List<SqlInt32> NumList;
    private SqlInt32 TheMedian;


    public void Init()
    {
        NumList = new List<SqlInt32>();
    }

    public void Accumulate(SqlInt32 Value)
    {
        NumList.Add(Value);            
    }

    public void Merge (Median Group)
    {

        this.NumList.AddRange(Group.NumList.ToArray());

    }

    public SqlInt32 Terminate ()
    {
        NumList.Sort();
        int Med  = NumList.Count / 2;
       
        if(NumList.Count % 2 == 1) {           
            TheMedian = NumList[Med];
        }
        else {
            TheMedian = (NumList[Med] + NumList[Med - 1]) / 2;
        }
        return TheMedian;
    }

    public void Read(System.IO.BinaryReader r)
    {
        int x = r.ReadInt32();
        this.NumList = new List<SqlInt32>(x);
        for (int i = 0; i < x; i++)
        {
            this.NumList.Add(r.ReadInt32());
        }
    }
    public void Write(System.IO.BinaryWriter w)
    {
        w.Write(this.NumList.Count);
        foreach (int i in this.NumList)
        {
            w.Write(i);
        }
    }
}
