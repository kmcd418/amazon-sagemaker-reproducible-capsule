import yaml
import argparse
from sagemaker import get_execution_role
from sagemaker.estimator import Framework


def get_config():
    with open("config.yaml") as f:
        config = yaml.load(f, Loader=yaml.SafeLoader)
    return config


def get_iam_role():
    iam_role = get_execution_role()
    return iam_role


def get_training_job(iam_role, cfg):
    estimator = ContainerEstimator(
        role=iam_role,
        image_uri=cfg["base_image"],
        entry_point=cfg["entry_point"],
        source_dir=cfg["source_dir"],
        hyperparameters=cfg["parameters"],
        instance_count=cfg["instance_count"],
        instance_type=cfg["instance_type"],
        disable_profiler=True,
    )
    return estimator


class ContainerEstimator(Framework):
    def __init__(
        self,
        entry_point,
        framework_version=None,
        py_version=None,
        source_dir=None,
        hyperparameters=None,
        image_uri=None,
        distribution=None,
        **kwargs
    ):
        super(ContainerEstimator, self).__init__(
            entry_point, source_dir, hyperparameters, image_uri=image_uri, **kwargs
        )
        self.framework_version = framework_version
        self.py_version = None

    def _configure_distribution(self, distributions):
        return None

    def create_model(
        self,
        model_server_workers=None,
        role=None,
        vpc_config_override=None,
        entry_point=None,
        source_dir=None,
        dependencies=None,
        image_uri=None,
        **kwargs
    ):
        return None


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--job_name", type=str, default="")
    parser.add_argument("--container_image", type=str, default="")
    args, _ = parser.parse_known_args()

    # IAM ROLE
    iam_role = get_iam_role()

    # CONFIG
    config = get_config()

    # RUN TRAINING JOB
    estimator = ContainerEstimator(
        role=iam_role,
        image_uri=args.container_image,
        entry_point="code/entrypoint.sh",
        source_dir=".",
        # hyperparameters=cfg["parameters"],
        instance_count=1,
        instance_type=config["run"]["instance_type"],
        disable_profiler=True,
    )
    estimator.fit(job_name=args.job_name)
