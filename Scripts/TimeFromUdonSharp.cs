#if VRC_SDK_VRCSDK3
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class TimeFromUdonSharp : UdonSharpBehaviour
{
    public MeshRenderer timePanel;
    void Start()
    {
        timePanel.material.SetFloat("_Hour", System.DateTime.Now.Hour);
        timePanel.material.SetFloat("_Minute", System.DateTime.Now.Minute);
        timePanel.material.SetFloat("_Second", System.DateTime.Now.Second);
    }
}
#endif