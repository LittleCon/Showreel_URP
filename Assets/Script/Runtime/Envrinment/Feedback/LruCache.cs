using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LruCache : MonoBehaviour
{
    /// <summary>
    /// TileTexture�Ľڵ��࣬ͨ���������
    /// </summary>
    public class NodeInfo
    {
        public int id = 0;
        public NodeInfo Next { get; set; }
        public NodeInfo Prev { get; set; }
    }
    /// <summary>
    /// ͷ�ڵ�
    /// </summary>
    private NodeInfo head = null;

    /// <summary>
    /// β�ڵ�
    /// </summary>
    private NodeInfo tail = null;
    private NodeInfo[] allNodes;

    public int First { get { return head.id; } }

    public void Init(int count)
    {
        allNodes = new NodeInfo[count];
        for(int i = 0; i < count; i++)
        {
            allNodes[i] = new NodeInfo() { id=i};
        }

        //��������
        for(int i = 0; i < count; i++)
        {
            //�ж��Ƿ��Ƕ�β����βԪ��Ϊnull
            allNodes[i].Next = (i + 1 < count) ? allNodes[i + 1] : null;
            //�ж��Ƿ��Ƕ���
            allNodes[i].Prev = (i != 0) ? allNodes[i - 1] : null;
        }

        head = allNodes[0];
        tail = allNodes[count - 1];
    }
    public bool SetActive(int id)
    {
        if (id < 0 || id >= allNodes.Length)
            return false;

        var node = allNodes[id];
        if (node == tail) return true;

        Remove(node);
        AddLast(node);

        return true;
    }

    /// <summary>
    /// ��ӵ�β�ڵ�
    /// </summary>
    /// <param name="node"></param>
    private void AddLast(NodeInfo node)
    {
        var lastTail = tail;
        lastTail.Next = node;
        tail = node;
        node.Prev = lastTail;
    }

    private void Remove(NodeInfo node)
    {
        if (head == node)
            head = node.Next;
        else
        {
            node.Prev.Next = node.Next;
            node.Next.Prev = node.Prev;
        }
    }
}
