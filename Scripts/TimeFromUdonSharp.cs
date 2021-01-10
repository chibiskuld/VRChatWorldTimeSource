using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class TimeFromUdonSharp : UdonSharpBehaviour
{
    void Start()
    {
        transform.position = new Vector3(System.DateTime.Now.Hour, System.DateTime.Now.Minute, System.DateTime.Now.Second);
    }
}