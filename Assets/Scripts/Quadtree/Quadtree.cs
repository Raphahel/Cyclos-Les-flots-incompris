using System.Collections;
using System.Collections.Generic;
using Unity.Jobs;
using UnityEngine;

public class Quadtree : MonoBehaviour
{
    public class Node 
    {
        Rect _bounds;
        Node[] _children;
        int _depth = -1;

        public HashSet<Boid> _data;

        public Node(Rect inBounds, int inDepth = 0)
        {
            _bounds = inBounds;
            _depth = inDepth;
        }

        public Rect GetBounds()
        {
            return _bounds;
        }
        
        public void AddData(Quadtree Owner, Boid datum)
        {
            if (_children == null)
            {
                if (_data == null) { _data = new(); }
                if ((_data.Count + 1 >= Owner.PreferredMaxDataPerNode) && CanSplit(Owner))
                {
                    SplitNode(Owner);
                }
                else
                {
                    _data.Add(datum);
                    //datum.SetParent(this);
                }
                return;
            }

            AddDataToChildren(Owner, datum);
        }

        bool CanSplit(Quadtree Owner)
        {
            return (_bounds.width >= (Owner.MinimumNodeSize * 2)) && (_bounds.height >= (Owner.MinimumNodeSize * 2));
        }

        void SplitNode(Quadtree Owner)
        {
            float HalfWidth = _bounds.width / 2f;
            float HalfHeight = _bounds.height / 2f;

            int newDepth = _depth + 1;

            _children = new Node[4]
            {
                new Node(new Rect(_bounds.xMin, _bounds.yMin, HalfWidth, HalfHeight), newDepth),
                new Node(new Rect(_bounds.xMin + HalfWidth, _bounds.yMin, HalfWidth, HalfHeight), newDepth),
                new Node(new Rect(_bounds.xMin, _bounds.yMin + HalfHeight, HalfWidth, HalfHeight), newDepth),
                new Node(new Rect(_bounds.xMin + HalfWidth, _bounds.yMin + HalfHeight, HalfWidth, HalfHeight), newDepth),
            };

            // distribute the data
            foreach(var datum in _data)
            {
                AddDataToChildren(Owner, datum);
            }

            _data = null;
        }

        void AddDataToChildren(Quadtree Owner, Boid datum)
        {
            foreach(var child in _children)
            {
                if (child.Contains(datum.position2D))
                {
                    child.AddData(Owner, datum);
                }
            }
        }

        public bool Contains(Vector2 other)
        {
            return _bounds.Contains(other);
        }

        bool Overlaps(Rect other)
        {
            return _bounds.Overlaps(other);
        }

        public void FindDataInBox(Rect SearchRect, HashSet<Boid> OutFoundData)
        {
            if (!Overlaps(SearchRect))
            {
                return;
            }

            if (_children == null)
            {
                if (_data == null || _data.Count == 0)
                    return;

                foreach(var b in _data)
                {
                    if (SearchRect.Contains(b.position2D)) {
                        OutFoundData.Add(b);
                    }
                }
                //OutFoundData.UnionWith(_data);

                return;
            }

            foreach (var Child in _children)
            {
                Child.FindDataInBox(SearchRect, OutFoundData);
            }
        }

        public void FindDataInRadius(Vector2 SearchLocation, float radius, HashSet<Boid> OutFoundData)
        {
            if (_depth != 0)
            {
                throw new System.InvalidOperationException("FindDataInRange cannot be run on anything other than the root node.");
            }

            Rect SearchRect = new Rect(SearchLocation.x - radius, SearchLocation.y - radius,
                                       radius * 2f, radius * 2f);

            FindDataInBox(SearchRect, OutFoundData);

            OutFoundData.RemoveWhere(Datum => {
                float TestRange = radius * 2;

                return (SearchLocation - Datum.position2D).sqrMagnitude > (TestRange * TestRange);
            });
        }

        public void RemoveAllData()
        {
            //_children = null;
            if (_children != null)
            {
                foreach (Node n in _children)
                {
                    n.RemoveAllData();
                }
            }
            _children = null;
            _data = null;
        }

        public List<Node> GetAllChildren()
        {
            List<Node> children = new List<Node>();
            if (_children != null)
            {
                foreach(Node n in _children)
                {
                    children.AddRange(n.GetAllChildren());
                }
            } else
            {
                children.Add(this);
            }
            return children;
        }

        public void RunGizmos()
        {
            Gizmos.color = Color.blue; 
            if (_children != null)
            {
                foreach(Node n in _children)
                {
                    n.RunGizmos();
                }
            } else
            {
                Gizmos.DrawWireCube(new Vector3(_bounds.center.x, 100, _bounds.center.y), new Vector3(_bounds.width, 1, _bounds.height));
            }
        }

        public int GetChildrenCount()
        {
            int count = 0;
            if (_children != null)
            {
                foreach(Node n in _children)
                {
                    count += n.GetChildrenCount();
                }
            } else
            {
                count += 1;
            }
            return count;
        }

        public void Update(Quadtree Owner)
        {
            if (_children != null)
            {
                foreach (Node n in _children)
                {
                    n.Update(Owner);
                }
                JoinNodes(Owner);
            }
        }

        public void JoinNodes(Quadtree Owner)
        {
                HashSet<Boid> boids = GetBoidsFromChildren();
                if (boids.Count <= Owner.PreferredMaxDataPerNode)
                {
                    _children = null;
                    _data = boids;
                }
        }

        public HashSet<Boid> GetBoidsFromChildren()
        {
            HashSet<Boid> boids = new();
            if (_children != null)
            {
                foreach(Node n in _children)
                {
                    boids.UnionWith(n.GetBoidsFromChildren());
                }
            } else
            {
                if (_data != null)
                {
                    boids.UnionWith(_data);
                }
            }
            return boids;
        }


        /*public void MoveBoids(Quadtree Owner)
        {
            if (_data != null)
            {
                HashSet<Boid> boidsToRemove = new();
                foreach (Boid boid in _data)
                {
                    
                    if (!_bounds.Contains(boid.position2D))
                    {
                        boidsToRemove.Add(boid);
                        Owner.AddData(boid);
                    }
                    
                }
                foreach (Boid boid in boidsToRemove)
                {
                    _data.Remove(boid);
                }
            }
        }*/

    }

    [field: SerializeField] public int PreferredMaxDataPerNode { get; private set; } = 15;
    [field: SerializeField] public int MinimumNodeSize { get; private set; } = 2;
    public Node root;

    public static Quadtree Instance { get; private set; }

    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(this);
        } else
        {
            Instance = this;
        }
    }

    /*private void Update()
    {
        root.Update(this);
    }*/

    public void PrepareTree(Rect bounds)
    {
        root = new Node(bounds);
    }

    public void AddData(Boid datum)
    {
        root.AddData(this, datum);
    }

    public void AddData(List<Boid> data)
    {
        foreach(Boid datum in data)
        {
            AddData(datum);
        }
    }

    public HashSet<Boid> FindDataInRange(Vector2 SearchLocation, float SearchRange)
    {

        HashSet<Boid> FoundData = new();
        root.FindDataInRadius(SearchLocation, SearchRange, FoundData);
        return FoundData;
    }

    public void RemoveAllData()
    {
        root.RemoveAllData();
    }

    private void OnDrawGizmos() { if (root != null) { root.RunGizmos(); } }

    private List<Node> GetAllChildren()
    {
        return root.GetAllChildren();
    }

    public int GetChildrenCount() { return root.GetChildrenCount(); }

}
