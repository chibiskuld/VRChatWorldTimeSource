using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class TimeFromUdonSharp : UdonSharpBehaviour
{
    public Material[] materials;
    void Start()
    {
        transform.position = new Vector3(System.DateTime.Now.Hour, System.DateTime.Now.Minute, System.DateTime.Now.Second);
        foreach ( Material material in materials)
        {
            material.SetVector("_FeedTime", new Vector4(System.DateTime.Now.Hour, System.DateTime.Now.Minute, System.DateTime.Now.Second, 1));
        }
    }
}