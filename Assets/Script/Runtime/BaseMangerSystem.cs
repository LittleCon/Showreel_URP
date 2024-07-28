using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace FC
{
    public class BaseMangerSystem <T> : MonoBehaviour where T: MonoBehaviour
    {
        private static T m_Instance;
        public static T Instance
        {
            get
            {
                return m_Instance;
            }
        }

        protected virtual void Awake()
        {
            if (m_Instance == null)
            {
                m_Instance = this as T;
            }
        }
    }
}
